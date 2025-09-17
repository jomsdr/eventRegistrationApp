<template>
  <div class="flex h-screen w-full items-center justify-center px-4">
    <RegistrationEditForm
      :model-value="form"
      :error="error"
      @submit="handleSubmit"
      @cancel="goBack"
    />
  </div>
</template>

<script setup>

import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import axios from 'axios';
import RegistrationEditForm from '@/components/RegistrationEditForm.vue';
import { useSessionManagerStore } from '@/store/sessionManager';

const API_URL = import.meta.env.VITE_API_URL;
const route = useRoute();
const router = useRouter();
const sessionManager = useSessionManagerStore();
const form = ref({ name: '', email: '' });
const error = ref('');

const eventId = route.params.eventId || route.params.id;
const registrationId = route.params.registrationId || route.params.regId || route.params.id;

onMounted(async () => {
  try {
    const res = await axios.get(`${API_URL}/events/${eventId}/registrations/${registrationId}`);
    // Assign a new object to trigger reactivity in child
    form.value = { name: res.data.name, email: res.data.email };
  } catch (e) {
    error.value = 'Failed to load registration.';
  }
});


async function handleSubmit(payload) {
  // Frontend validation
  error.value = '';
  if (!payload.name) {
    error.value = 'Name is required.';
    return;
  }
  if (!payload.email) {
    error.value = 'Email is required.';
    return;
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(payload.email)) {
    error.value = 'Email is invalid.';
    return;
  }
  try {
    await axios.patch(`${API_URL}/events/${eventId}/registrations/${registrationId}`, {
      registration: { name: payload.name, email: payload.email }
    });
    if (sessionManager.isAdmin) {
      router.push('/admin');
    } else {
      router.push(`/events/${eventId}`);
    }
  } catch (e) {
    error.value = e.response?.data?.error || 'Failed to update registration.';
  }
}

function goBack() {
  if (sessionManager.isAdmin) {
    router.push('/admin');
  } else {
    router.push(`/events/${eventId}`);
  }
}
</script>
