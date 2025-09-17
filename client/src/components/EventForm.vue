<template>
  <div class="flex h-screen w-full items-center justify-center px-4">
    <Card class="w-full max-w-sm">
      <CardHeader>
        <CardTitle class="text-2xl">
          {{ mode === 'edit' ? 'Edit Event' : 'New Event' }}
        </CardTitle>
        <CardDescription>
          {{ mode === 'edit'
            ? 'Update the event information below.'
            : 'Create a new event by filling in the information below.' }}
        </CardDescription>
      </CardHeader>

      <CardContent class="grid gap-4">
        <!-- Name -->
        <div class="grid gap-2">
          <Label for="name">Event Name</Label>
          <Input
            id="name"
            type="text"
            placeholder="Event Name"
            v-model="form.title"
            required
          />
        </div>

        <!-- Date -->
        <div class="grid gap-2">
          <Label for="date">Date</Label>
          <Input
            id="date"
            type="date"
            v-model="form.date"
            required
          />
        </div>

        <!-- Location -->
        <div class="grid gap-2">
          <Label for="location">Location</Label>
          <Input
            id="location"
            type="text"
            placeholder="Location"
            v-model="form.location"
            required
          />
        </div>

        <!-- Description -->
        <div class="grid gap-2">
          <Label for="description">Description</Label>
          <textarea
            id="description"
            class="border rounded px-3 py-2 w-full"
            placeholder="Event description"
            v-model="form.description"
            rows="4"
            required
          ></textarea>
        </div>

        <!-- Validation Errors -->
        <div v-if="errors.length" class="text-red-500 text-sm">
          <ul>
            <li v-for="(error, idx) in errors" :key="idx">{{ error }}</li>
          </ul>
        </div>
      </CardContent>

      <CardFooter class="flex justify-between">
        <Button class="w-1/2 mr-2" @click="handleSave">
          {{ mode === 'edit' ? 'Update' : 'Save' }}
        </Button>
        <Button class="w-1/2 ml-2" variant="outline" @click="handleCancel">Cancel</Button>
      </CardFooter>
    </Card>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import axios from "axios";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useSessionManagerStore } from '@/store/sessionManager';

const API_URL = import.meta.env.VITE_API_URL;

import { useRoute } from "vue-router";

const props = defineProps({
  mode: {
    type: String,
    default: "create" // or "edit"
  }
});

const router = useRouter();
const sessionManager = useSessionManagerStore();

const form = ref({
  title: "",
  date: "",
  location: "",
  description: "",
});

const errors = ref([]);


const route = useRoute();

// Fetch event data if editing
const fetchEventData = async () => {
  if (props.mode === "edit" && route.params.id) {
    try {
      const res = await axios.get(`${API_URL}/events/${route.params.id}`);
      let event = res.data;
      // Format date as yyyy-MM-dd for input type="date"
      let formattedDate = event.date;
      if (formattedDate) {
        const d = new Date(formattedDate);
        if (!/^\d{4}-\d{2}-\d{2}$/.test(formattedDate)) {
          formattedDate = d.toISOString().slice(0, 10);
        }
      }
      form.value = { ...form.value, ...event, date: formattedDate };
    } catch (e) {
      errors.value = ["Failed to load event data."];
    }
  }
};

if (props.mode === "edit") {
  fetchEventData();
}

const validate = () => {
  errors.value = [];
  if (!form.value.title) errors.value.push("Event title is required.");
  if (!form.value.date) errors.value.push("Date is required.");
  if (!form.value.location) errors.value.push("Location is required.");
  if (!form.value.description) errors.value.push("Description is required.");
  return errors.value.length === 0;
};

const handleSave = async () => {
  if (!validate()) return;
  try {
    if (props.mode === "edit") {
      // Update event
      await axios.put(`${API_URL}/events/${route.params.id}`, { event: form.value });
    } else {
      // Create event
      await axios.post(`${API_URL}/events`, { event: form.value });
    }
    if (sessionManager.isAdmin) {
      router.push("/admin");
    } else {
      router.push("/events");
    }
  } catch (error) {
    errors.value = ["Failed to save event. Please try again."];
  }
};

const handleCancel = () => {
  if (sessionManager.isAdmin) {
    router.push("/admin");
  } else {
    router.push("/events");
  }
};
</script>