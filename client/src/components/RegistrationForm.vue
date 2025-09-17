<template>
	<div class="w-full max-w-md mx-auto bg-white rounded-lg shadow-md p-8">
		<h2 class="text-2xl font-bold mb-4">Register for Event</h2>
		<form @submit.prevent="handleSubmit" class="space-y-4">
			<div>
				<label for="name" class="block font-medium mb-1">Attendee Name</label>
				<input
					id="name"
					v-model="form.name"
					type="text"
					class="border rounded px-3 py-2 w-full"
					placeholder="Name"
					required
				/>
			</div>
			<div>
				<label for="email" class="block font-medium mb-1">Email</label>
				<input
					id="email"
					v-model="form.email"
					type="email"
					class="border rounded px-3 py-2 w-full"
					placeholder="foo@email.com"
					required
				/>
			</div>
			<div v-if="errors.length" class="text-red-500 text-sm">
				<ul>
					<li v-for="(error, idx) in errors" :key="idx">{{ error }}</li>
				</ul>
			</div>
			<div v-if="success" class="text-green-600 text-sm mb-2">Registration submitted successfully!</div>
            <Button class="w-full">
                Register
            </Button>
        </form>

    </div>
</template>

<script setup>
import { ref, defineEmits } from 'vue';
import axios from 'axios';

import { Button } from "@/components/ui/button";

const API_URL = import.meta.env.VITE_API_URL;

const props = defineProps({
    eventId: {
        type: [String, Number],
        required: true
    }
});

const emit = defineEmits(['registered']);

const form = ref({
    name: '',
    email: '',
});
const errors = ref([]);
const success = ref(false);

function validate() {
    errors.value = [];
    if (!form.value.name) errors.value.push('Name is required.');
    if (!form.value.email) {
        errors.value.push('Email is required.');
    } else if (!/^\S+@\S+\.\S+$/.test(form.value.email)) {
        errors.value.push('Email is invalid.');
    }
    return errors.value.length === 0;
}

async function handleSubmit() {
    if (!validate()) return;
    try {
        await axios.post(`${API_URL}/events/${props.eventId}/registrations`, 
        {
            registration: { ...form.value }
        },
        {
            headers: { 'Accept': 'application/json', 'Content-Type': 'application/json' }
        });
        success.value = true;
        form.value = { name: '', email: '' };
        errors.value = [];
        emit('registered');
    } catch (e) {
        errors.value = [
            e.response?.data?.error || 'Failed to submit registration.'
        ];
        success.value = false;
    }
}
</script>
