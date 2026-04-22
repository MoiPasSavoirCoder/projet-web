<script setup>
import { RouterView, RouterLink } from 'vue-router';
</script>

<template>
  <div class="u-sidebar">
    <aside>
      <h3>Administration</h3>
      <nav>
        <RouterLink to="/admin/dashboard"><i class="pi pi-chart-bar" /> Dashboard</RouterLink>
        <RouterLink to="/admin/users"><i class="pi pi-users" /> Utilisateurs</RouterLink>
        <RouterLink to="/admin/alertes"><i class="pi pi-bell" /> Alertes</RouterLink>
        <RouterLink to="/admin/audit"><i class="pi pi-history" /> Audit</RouterLink>
      </nav>
    </aside>
    <section class="content"><RouterView /></section>
  </div>
</template>
