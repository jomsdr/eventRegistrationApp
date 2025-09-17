<template>
  <div class="min-h-screen bg-zinc-100 text-zinc-900 p-8">
    <div class="max-w-7xl mx-auto">
      <h1 class="text-3xl font-bold mb-8">Admin Dashboard</h1>
      <!-- Stats Cards -->
      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-6 mb-10">
        <Card>
          <CardHeader><CardTitle>Total Events</CardTitle></CardHeader>
          <CardContent><div class="text-3xl font-bold">{{ stats.totalEvents }}</div></CardContent>
        </Card>
        <Card>
          <CardHeader><CardTitle>Total Attendees</CardTitle></CardHeader>
          <CardContent><div class="text-3xl font-bold">{{ stats.totalAttendees }}</div></CardContent>
        </Card>
      </div>

      <!-- Tabs -->
      <div class="mb-8">
        <div class="flex gap-4 border-b border-zinc-800 mb-4">
          <button
            class="px-4 py-2 text-lg font-medium focus:outline-none transition-colors"
            :class="tab==='events' ? 'border-b-2 border-primary text-primary' : 'text-zinc-400'"
            @click="tab='events'"
          >Events</button>
          <button
            class="px-4 py-2 text-lg font-medium focus:outline-none transition-colors"
            :class="tab==='registrations' ? 'border-b-2 border-primary text-primary' : 'text-zinc-400'"
            @click="tab='registrations'"
          >Registrations</button>
        </div>
      </div>

      <!-- Event Management Table -->
      <div v-if="tab==='events'">
        <div class="flex items-center gap-4 mb-4">
          <Input v-model="eventSearch" placeholder="Search events..." class="w-64" />
          <Button variant="destructive" @click="bulkDeleteEvents" :disabled="!selectedEventIds.length">Bulk Delete</Button>
          <Button variant="outline" @click="exportEvents">Export</Button>
        </div>

  <div class="overflow-x-auto rounded-lg">
          <table class="min-w-full text-zinc-900">
            <thead>
              <tr>
                <th class="p-2 align-middle text-center w-10"><input type="checkbox" @change="toggleAllEvents" :checked="allEventsSelected" class="align-middle mx-auto" /></th>
                <th class="p-2 text-left">Title</th>
                <th class="p-2 text-left">Date</th>
                <th class="p-2 text-left">Location</th>
                <th class="p-2 text-left">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="event in filteredEvents" :key="event.id" class="border-b border-zinc-800">
                <td class="p-2"><input type="checkbox" v-model="selectedEventIds" :value="event.id" /></td>
                <td class="p-2">{{ event.title }}</td>
                <td class="p-2">{{ formatDate(event.date) }}</td>
                <td class="p-2">{{ event.location }}</td>
                <td class="p-2 flex gap-2">
                  <Button size="sm" variant="outline" @click="viewEvent(event.id)">View</Button>
                  <Button size="sm" variant="outline" @click="editEvent(event.id)">Edit</Button>
                  <Button size="sm" variant="destructive" @click="deleteEvent(event.id)">Delete</Button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Registration Management Table -->
      <div v-if="tab==='registrations'">
        <div class="flex items-center gap-4 mb-4">
          <Input v-model="registrationSearch" placeholder="Search registrations (event or attendee)..." class="w-64" />
          <Button variant="destructive" @click="bulkDeleteRegistrations" :disabled="!selectedRegistrationIds.length">Bulk Delete</Button>
          <Button variant="outline" @click="exportRegistrations">Export</Button>
        </div>
  <div class="overflow-x-auto rounded-lg">
          <table class="min-w-full text-zinc-900">
            <thead>
              <tr>
                <th class="p-2 align-middle text-center w-10"><input type="checkbox" @change="toggleAllRegistrations" :checked="allRegistrationsSelected" class="align-middle mx-auto" /></th>
                <th class="p-2 text-left">Attendee</th>
                <th class="p-2 text-left">Email</th>
                <th class="p-2 text-left">Event</th>
                <th class="p-2 text-left">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="reg in filteredRegistrations" :key="reg.id" class="border-b border-zinc-800">
                <td class="p-2"><input type="checkbox" v-model="selectedRegistrationIds" :value="reg.id" /></td>
                <td class="p-2">{{ reg.name }}</td>
                <td class="p-2">{{ reg.email }}</td>
                <td class="p-2">{{ reg.event_title }}</td>
                <td class="p-2 flex gap-2">
                  <!-- <Button size="sm" variant="outline" @click="viewRegistration(reg.id)">View</Button> -->
                  <Button size="sm" variant="outline" @click="editRegistration(reg)">Edit</Button>
                  <Button size="sm" variant="destructive" @click="deleteRegistration(reg.id)">Delete</Button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL;
const stats = ref({
  totalEvents: 0,
  totalAttendees: 0
});
const tab = ref('events');
const router = useRouter();

// Events
const events = ref([]);
const eventSearch = ref('');
const selectedEventIds = ref([]);
const allEventsSelected = computed(() => selectedEventIds.value.length === filteredEvents.value.length && filteredEvents.value.length > 0);

const filteredEvents = computed(() => {
  if (!eventSearch.value) return events.value;
  return events.value.filter(e => e.title.toLowerCase().includes(eventSearch.value.toLowerCase()));
});

// Registrations
const registrations = ref([]);
const registrationSearch = ref('');
const selectedRegistrationIds = ref([]);
const allRegistrationsSelected = computed(() => selectedRegistrationIds.value.length === filteredRegistrations.value.length && filteredRegistrations.value.length > 0);

const filteredRegistrations = computed(() => {
  if (!registrationSearch.value) return registrations.value;
  return registrations.value.filter(r =>
    (r.name && r.name.toLowerCase().includes(registrationSearch.value.toLowerCase())) ||
    (r.email && r.email.toLowerCase().includes(registrationSearch.value.toLowerCase())) ||
    (r.event_title && r.event_title.toLowerCase().includes(registrationSearch.value.toLowerCase()))
  );
});

onMounted(async () => {
  await fetchStats();
  await fetchEvents();
  await fetchRegistrations();
});

async function fetchStats() {
  const [eventsRes, regsRes] = await Promise.all([
    axios.get(`${API_URL}/admin/events`),
    axios.get(`${API_URL}/admin/registrations`)
  ]);
  const events = eventsRes.data;
  const regs = regsRes.data;
  stats.value.totalEvents = events.length;
  stats.value.totalAttendees = regs.length;
}

async function fetchEvents() {
  const res = await axios.get(`${API_URL}/admin/events`);

  console.log(res)

  events.value = res.data;
}

async function fetchRegistrations() {
  const res = await axios.get(`${API_URL}/admin/registrations`);

  // Add event_title for display
  registrations.value = res.data.map(r => ({ ...r, event_title: r.event?.title || '' }));
}

function formatDate(dateStr) {
  if (!dateStr) return '';
  const date = new Date(dateStr);
  return date.toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' });
}

function toggleAllEvents(e) {
  if (e.target.checked) {
    selectedEventIds.value = filteredEvents.value.map(ev => ev.id);
  } else {
    selectedEventIds.value = [];
  }
}

function toggleAllRegistrations(e) {
  if (e.target.checked) {
    selectedRegistrationIds.value = filteredRegistrations.value.map(r => r.id);
  } else {
    selectedRegistrationIds.value = [];
  }
}

async function bulkDeleteEvents() {
  if (!confirm('Delete selected events?')) return;
  await axios.delete(`${API_URL}/admin/events/bulk_delete`, { data: { event_ids: selectedEventIds.value } });
  await fetchEvents();
  await fetchStats();
  selectedEventIds.value = [];
}


async function deleteEvent(id) {
  if (!confirm('Delete this event?')) return;
  await axios.delete(`${API_URL}/admin/events/${id}`);
  await fetchEvents();
  await fetchStats();
}

function viewEvent(id) {
  router.push(`/events/${id}`);
}

async function bulkDeleteRegistrations() {
  if (!confirm('Delete selected registrations?')) return;
  await axios.delete(`${API_URL}/admin/registrations/bulk_delete`, { data: { registration_ids: selectedRegistrationIds.value } });
  await fetchRegistrations();
  await fetchStats();
  selectedRegistrationIds.value = [];
}

async function deleteRegistration(id) {
  if (!confirm('Delete this registration?')) return;
  await axios.delete(`${API_URL}/admin/registrations/${id}`);
  await fetchRegistrations();
  await fetchStats();
}

async function exportRegistrations() {
  const response = await axios.get(`${API_URL}/admin/registrations/export`, {
    responseType: 'blob',
  });
  const url = window.URL.createObjectURL(new Blob([response.data]));
  const link = document.createElement('a');
  link.href = url;
  link.setAttribute('download', `events-${new Date().toISOString().slice(0,10)}.csv`);
  document.body.appendChild(link);
  link.click();
  link.remove();
}

async function exportEvents() {
  const response = await axios.get(`${API_URL}/admin/events/export`, {
    responseType: 'blob',
  });
  const url = window.URL.createObjectURL(new Blob([response.data]));
  const link = document.createElement('a');
  link.href = url;
  link.setAttribute('download', `events-${new Date().toISOString().slice(0,10)}.csv`);
  document.body.appendChild(link);
  link.click();
  link.remove();
}

function editEvent(id) {
  router.push({ name: 'EventEdit', params: { id } });
}

function editRegistration(reg) {
  // reg.event_id and reg.id are required for the route
  router.push({ name: 'RegistrationEdit', params: { eventId: reg.event_id || reg.event?.id, registrationId: reg.id } });
}
</script>
