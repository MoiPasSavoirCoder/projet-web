<script setup>
import { RouterView, RouterLink } from 'vue-router';
</script>

<template>
  <div class="u-sidebar">
    <aside>
      <h3>Mon espace</h3>
      <nav>
        <RouterLink to="/app/compte"><i class="pi pi-user" /> Mon compte</RouterLink>
        <RouterLink to="/app/historique"><i class="pi pi-list" /> Mes commandes</RouterLink>
        <RouterLink to="/app/favoris"><i class="pi pi-heart" /> Favoris</RouterLink>
        <RouterLink to="/app/liste-courses"><i class="pi pi-shopping-cart" /> Liste de courses</RouterLink>
        <RouterLink to="/app/alertes"><i class="pi pi-bell" /> Alertes</RouterLink>
      </nav>
    </aside>
    <section class="content"><RouterView /></section>
  </div>
</template>
