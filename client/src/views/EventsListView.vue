<template>
  <div class="min-h-screen bg-zinc-100 text-zinc-900 flex flex-col items-center w-full px-4 py-8">
    <div class="w-full max-w-2xl">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold">Events</h1>
        <Button @click="goToCreate">Create Event</Button>
      </div>
      <div v-if="loading" class="text-center text-gray-500 py-8">
        Loading events...
      </div>
      <div v-else-if="events.length === 0" class="text-center text-gray-500 py-8">
        No events found.
      </div>
      <div v-else>
        <div class="grid gap-4">
          <div
            v-for="event in events"
            :key="event.id"
            class="bg-white rounded-lg shadow-md p-6 flex flex-col md:flex-row md:items-center md:justify-between transition-transform hover:scale-[1.015] hover:shadow-lg border border-gray-100"
          >
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2 mb-1">
                <span class="font-semibold text-lg truncate">{{ event.title }}</span>
              </div>
              <div class="text-sm text-gray-500 mb-1">
                <span class="font-medium text-gray-700">Date:</span> {{ formatDate(event.date) }}
                <span class="mx-2">|</span>
                <span class="font-medium text-gray-700">Location:</span> {{ event.location }}
              </div>
            </div>
            <div class="flex gap-2 mt-4 md:mt-0 md:ml-6">
              <Button size="sm" variant="outline" class="hover:gray-50" @click="goToShow(event.id)">Show</Button>
              <Button size="sm" variant="outline" class="hover:bg-gray-50" @click="goToEdit(event.id)">Edit</Button>
              <Button size="sm" variant="destructive" class="hover:bg-red-700" @click="handleDelete(event.id)">Delete</Button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
    import { ref, onMounted } from 'vue';
    import { useRouter } from 'vue-router';
    import axios from 'axios';
    import { Button } from '@/components/ui/button';

    const API_URL = import.meta.env.VITE_API_URL;
    const router = useRouter();
    const events = ref([]);
    const loading = ref(true);

    const fetchEvents = async () => {
    loading.value = true;
    try {
        const res = await axios.get(`${API_URL}/events`);
        events.value = res.data;
    } catch (error) {
        events.value = [];
    } finally {
        loading.value = false;
    }
    };

    onMounted(fetchEvents);

    const goToCreate = () => {
        router.push('/events/new');
    };
    const goToShow = (id) => {
        router.push(`/events/${id}`);
    };
    const goToEdit = (id) => {
        router.push(`/events/${id}/edit`);
    };
    const handleDelete = async (id) => {
        if (!confirm('Are you sure you want to delete this event?')) return;
        try {
            await axios.delete(`${API_URL}/events/${id}`);
            fetchEvents();
        } catch (error) {
            alert('Failed to delete event.');
        }
    };

    function formatDate(dateStr) {
        if (!dateStr) return '';
            const date = new Date(dateStr);
        return date.toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' });
    }
</script>
