<script setup>
import { useRoute } from 'vue-router'
import { useSessionManagerStore } from '@/store/sessionManager'
import AppNavbar from '@/components/AppNavbar.vue'

const route = useRoute()
const sessionManager = useSessionManagerStore()

const hideNavbarRoutes = ['/login', '/signup']
</script>

<template>
  <div>
    <AppNavbar v-if="sessionManager.user && !hideNavbarRoutes.includes(route.path)" />
    <RouterView />
  </div>
</template>