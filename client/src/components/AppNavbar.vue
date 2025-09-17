<template>
  <nav class="w-full bg-zinc-900 border-b border-zinc-800 shadow-sm flex items-center justify-between px-6 py-3">
    <div class="flex items-center gap-2">
      <span class="font-bold text-xl text-zinc-100">Event Registration</span>
    </div>
    <div class="flex items-center gap-4">
      <span v-if="sessionManager.user" class="text-zinc-200">Hello, {{ sessionManager.user.name || sessionManager.user.email }}!</span>
      <Button
        v-if="sessionManager.user"
        variant="outline"
        class="border-zinc-600 text-zinc-100 bg-zinc-800 hover:bg-zinc-700 hover:text-white focus:ring-2 focus:ring-zinc-500 focus:outline-none transition-colors"
        @click="handleLogout"
      >
        Logout
      </Button>
    </div>
  </nav>
</template>

<script setup>
import { Button } from '@/components/ui/button';
import { useRouter } from 'vue-router';
import { useSessionManagerStore } from '@/store/sessionManager';

const router = useRouter();
const sessionManager = useSessionManagerStore();

const handleLogout = async () => {
  try {
    await sessionManager.logoutUser();
    router.push('/login');
  } catch (error) {
    console.error('Logout failed:', error);
    alert('Logout failed. Please try again.');
  }
};

</script>

<style scoped>
nav {
  z-index: 50;
  /* fallback for dark mode if zinc classes are not available */
  background: #18181b;
  border-color: #27272a;
}
</style>
