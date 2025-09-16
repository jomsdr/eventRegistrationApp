<template>
    <div class="flex h-screen w-full items-center justify-center px-4">
        <h1>Dashboard</h1>

    <Button @click="handleLogout">
        Log Out
    </Button>
    </div>


</template>

<script setup>

import { useSessionManagerStore } from '@/store/sessionManager';
import { useRouter } from 'vue-router';

const sessionManager = useSessionManagerStore();
const router = useRouter();

import { Button } from "@/components/ui/button";

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
