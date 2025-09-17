<template>
  <Card class="w-full max-w-sm">
    <CardHeader>
      <CardTitle class="text-2xl">
        Login
      </CardTitle>
      <CardDescription>
        Enter your email below to login to your account.
      </CardDescription>
    </CardHeader>
    <CardContent class="grid gap-4">
      <div class="grid gap-2">
        <Label for="email">Email</Label>
        <Input id="email" type="email" placeholder="m@example.com" v-model="form.email" required />
      </div>
      <div class="grid gap-2">
        <Label for="password">Password</Label>
        <Input id="password" type="password" v-model="form.password" required />
      </div>
    </CardContent>
    <CardFooter>
      <Button class="w-full" @click="handleLogin">
        Sign in
      </Button>
    </CardFooter>

    <div class="mt-4 text-center text-sm">
      Don't have an account?
      <a href="/signup" class="underline underline-offset-4">Sign up</a>
    </div>
      
  </Card>
</template>

<script setup>

import { ref } from "vue"
import { useRouter } from "vue-router"
import { useSessionManagerStore } from '@/store/sessionManager'

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

const API_URL = import.meta.env.VITE_API_URL;
const router = useRouter()

const form = ref({
  email: "",
  password: "",
})

const sessionManager = useSessionManagerStore();

const handleLogin = async () => {
  try {
    await sessionManager.loginUser({
      user: {
        email: form.value.email,
        password: form.value.password,
      },
    });

    if (sessionManager.isAdmin) {
      router.push('/admin');
    } else {
      router.push('/events');
    }
  } catch (error) {
    console.error("Login failed:", error);
    alert("Invalid email or password");
  }
}
</script>