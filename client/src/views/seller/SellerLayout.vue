<script setup>
import { RouterView, RouterLink } from 'vue-router';
</script>

<template>
  <div class="u-sidebar">
    <aside>
      <h3>Espace producteur</h3>
      <nav>
        <RouterLink to="/seller/commandes"><i class="pi pi-list" /> Commandes</RouterLink>
        <RouterLink to="/seller/produits"><i class="pi pi-shopping-bag" /> Mes produits</RouterLink>
      </nav>
    </aside>
    <section class="content"><RouterView /></section>
  </div>
</template>
