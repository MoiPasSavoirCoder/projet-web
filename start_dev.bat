@echo off
REM ─────────────────────────────────────────────────────────────────────────────
REM  gumes marketplace - local dev startup (without Docker)
REM
REM  Uses a local PostgreSQL via DATABASE_URL in .env.
REM  Resets public schema + extensions, runs migrations + seed,
REM  then starts server (:3000) and client (:5173).
REM ─────────────────────────────────────────────────────────────────────────────
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"

where psql >nul 2>&1
if errorlevel 1 (
  echo Error: psql not found ^(PostgreSQL client is required^).
  exit /b 1
)

where node >nul 2>&1
if errorlevel 1 (
  echo Error: node not found ^(node ^>= 20 required^).
  exit /b 1
)

REM -- .env --------------------------------------------------------------------
if not exist .env (
  echo --^> Creating .env from .env.example
  copy /Y .env.example .env >nul
  for /f "usebackq delims=" %%S in (`node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`) do set "SECRET=%%S"
  powershell -NoProfile -Command "(Get-Content .env) -replace '^SESSION_SECRET=.*', 'SESSION_SECRET=%SECRET%' | Set-Content .env"
  echo     SESSION_SECRET generated.
  echo     Update DATABASE_URL in .env to point to your local PostgreSQL.
)

REM -- Load .env values into process env ----------------------------------------
for /f "usebackq tokens=1,* delims==" %%A in (`powershell -NoProfile -Command "$lines = Get-Content '.env' ^| Where-Object { $_ -match '^\s*[^#].*=.*$' }; foreach($l in $lines){ $i = $l.IndexOf('='); $k = $l.Substring(0,$i).Trim(); $v = $l.Substring($i+1); Write-Output ($k + '=' + $v) }"`) do (
  set "%%A=%%B"
)

if "%DATABASE_URL%"=="" (
  echo Error: DATABASE_URL is missing in .env.
  exit /b 1
)

REM -- Connection check ----------------------------------------------------------
echo --^> Checking PostgreSQL connection...
psql "%DATABASE_URL%" -c "\q" >nul 2>nul
if errorlevel 1 (
  echo Cannot connect to DATABASE_URL.
  echo Verify PostgreSQL is running and user/database exist, for example:
  echo   psql -U postgres -c "CREATE USER %POSTGRES_USER% WITH PASSWORD '%POSTGRES_PASSWORD%' SUPERUSER;"
  echo   psql -U postgres -c "CREATE DATABASE %POSTGRES_DB% OWNER %POSTGRES_USER%;"
  exit /b 1
)
echo     Database reachable.

REM -- Reset schema + extensions ------------------------------------------------
echo --^> Resetting public schema + extensions...
set "TMP_SQL=%TEMP%\gumes_reset_%RANDOM%%RANDOM%.sql"
(
  echo DROP EXTENSION IF EXISTS postgis CASCADE;
  echo DROP EXTENSION IF EXISTS pgcrypto CASCADE;
  echo DROP EXTENSION IF EXISTS citext CASCADE;
  echo DROP SCHEMA IF EXISTS public CASCADE;
  echo CREATE SCHEMA public;
  echo GRANT ALL ON SCHEMA public TO public;
  echo CREATE EXTENSION postgis;
  echo CREATE EXTENSION pgcrypto;
  echo CREATE EXTENSION citext;
) > "%TMP_SQL%"

psql "%DATABASE_URL%" -v ON_ERROR_STOP=1 -f "%TMP_SQL%" >nul
if errorlevel 1 (
  del "%TMP_SQL%" >nul 2>&1
  echo Failed to reset schema/extensions. Check extension rights ^(postgis/pgcrypto/citext^).
  exit /b 1
)
del "%TMP_SQL%" >nul 2>&1

REM -- Dependencies --------------------------------------------------------------
if not exist node_modules (
  goto :install_deps
)
if not exist server\node_modules (
  goto :install_deps
)
if not exist client\node_modules (
  goto :install_deps
)
goto :deps_done

:install_deps
echo --^> Installing npm dependencies...
call npm install
if errorlevel 1 (
  echo npm install failed.
  exit /b 1
)

:deps_done
REM -- Migrations + seed ---------------------------------------------------------
echo --^> Running migrations...
call npm run db:migrate
if errorlevel 1 (
  echo Migration failed.
  exit /b 1
)

echo --^> Seeding demo data...
call npm run db:seed
if errorlevel 1 (
  echo Seed failed.
  exit /b 1
)

REM -- Start server + client in separate windows --------------------------------
echo.
echo ======================================================================
echo   gumes marketplace is ready ^(local dev, without Docker^).
echo     - API     http://localhost:3000
echo     - Client  http://localhost:5173
echo.
echo   Demo accounts ^(password: GumesDev!2026^)
echo     admin@gumes.local ^| producteur1@gumes.local ... ^| client1@gumes.local ...
echo.
echo   Close the two launched windows to stop server and client.
echo ======================================================================
echo.

start "gumes server" cmd /k "npm run dev:server"
start "gumes client" cmd /k "npm run dev:client"

endlocal
exit /b 0
