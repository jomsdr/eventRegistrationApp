<template>
    <div class="min-h-screen bg-zinc-100 text-zinc-900 flex items-center justify-center px-4">
        <EventForm :mode="mode" />
    </div>
</template>

<script setup>
    import { useRoute } from 'vue-router';
    import EventForm from "@/components/EventForm.vue";

    const route = useRoute();
    const mode = route.params.id ? 'edit' : 'create';
</script>
