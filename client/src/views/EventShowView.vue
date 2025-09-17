<template>
  <div v-bind="$attrs" class="min-h-screen bg-zinc-100 text-zinc-900 flex flex-col items-center w-full px-4 py-8">
    <div class="w-full max-w-xl bg-white rounded-lg shadow-md p-8">
      <div class="mb-6">
        <h1 class="text-3xl font-bold mb-2">{{ event.title }}</h1>
        <div class="text-gray-600 mb-1">
          <span class="font-medium">Date:</span> {{ formatDate(event.date) }}
          <span class="mx-2">|</span>
          <span class="font-medium">Location:</span> {{ event.location }}
        </div>
      </div>
      <div class="mb-6">
        <h2 class="text-lg font-semibold mb-2">Description</h2>
        <p class="whitespace-pre-line text-gray-800">{{ event.description }}</p>
      </div>
      <div class="flex gap-2">
        <Button variant="outline" @click="goToEdit">Edit</Button>
        <Button variant="destructive" class="hover:bg-red-700" @click="goToDelete">Delete</Button>
        <Button @click="goToList">Back to List</Button>
      </div>
    </div>
  <RegistrationForm v-if="event.id" :eventId="event.id" class="mt-8 w-full max-w-xl" @registered="fetchRegistrations" />

    <div v-if="event.id" class="w-full max-w-xl mt-8">
      <div class="bg-white rounded-lg shadow-md p-8">
        <h3 class="text-xl font-bold mb-4">Registrations List</h3>
        <div v-if="loading" class="text-gray-500">Loading registrations...</div>
        <div v-else-if="registrations.length === 0" class="text-gray-500">No registrations yet.</div>
        <div v-else class="space-y-2">
          <div v-for="reg in registrations" :key="reg.id" class="flex items-center justify-between bg-gray-50 rounded px-4 py-2">
            <div>
              <div class="font-medium">{{ reg.name }}</div>
              <div class="text-xs text-gray-500">{{ reg.email }}</div>
            </div>
            <div class="flex gap-2">
              <Button size="sm" variant="outline" @click="goToEditRegistration(reg)">Edit</Button>
              <Button size="sm" variant="destructive" @click="deleteRegistration(reg.id)">Delete</Button>
            </div>
          </div>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup>
defineOptions({ inheritAttrs: false });
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import axios from 'axios';
import { Button } from '@/components/ui/button';
import RegistrationForm from '@/components/RegistrationForm.vue';
import { useSessionManagerStore } from '@/store/sessionManager';

const API_URL = import.meta.env.VITE_API_URL;
const route = useRoute();
const router = useRouter();
const event = ref({});

const registrations = ref([]);
const loading = ref(true);
const sessionManager = useSessionManagerStore();


const fetchEvent = async () => {
  try {
    const res = await axios.get(`${API_URL}/events/${route.params.id}`);
    event.value = res.data;
  } catch (error) {
    event.value = {};
  }
};

onMounted(() => {
  fetchEvent();
  fetchRegistrations();
});

function formatDate(dateStr) {
  if (!dateStr) return '';
  const date = new Date(dateStr);
  return date.toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' });
}

const goToEdit = () => {
  router.push(`/events/${route.params.id}/edit`);
};
const goToDelete = async () => {
  if (!confirm('Are you sure you want to delete this event?')) return;
  try {
    await axios.delete(`${API_URL}/events/${route.params.id}`);
    if (sessionManager.isAdmin) {
      router.push('/admin');
    } else {
      router.push('/events');
    }
  } catch (error) {
    alert('Failed to delete event.');
  }
};
const goToList = () => {
  if (sessionManager.isAdmin) {
    router.push('/admin');
  } else {
    router.push('/events');
  }
};



async function fetchRegistrations() {
  loading.value = true;
  try {
    const res = await axios.get(`${API_URL}/events/${route.params.id}/registrations`);
    registrations.value = res.data;
  } catch (e) {
    registrations.value = [];
  } finally {
    loading.value = false;
  }
}


function goToEditRegistration(reg) {
  router.push(`/events/${route.params.id}/registrations/${reg.id}/edit`);
}

async function deleteRegistration(id) {
  if (!confirm('Are you sure you want to delete this registration?')) return;
  try {
    await axios.delete(`${API_URL}/events/${route.params.id}/registrations/${id}`);
    fetchRegistrations();
  } catch (e) {
    alert(e.response?.data?.error || 'Failed to delete registration.');
  }
}
</script>
