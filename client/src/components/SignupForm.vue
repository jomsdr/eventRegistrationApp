<template>
  <Card class="w-full max-w-sm">
    <CardHeader>
      <CardTitle class="text-2xl">
        Sign Up
      </CardTitle>
      <CardDescription>
        Create a new account by filling in the information below.
      </CardDescription>
    </CardHeader>

    <CardContent class="grid gap-4">
      <!-- Name -->
      <div class="grid gap-2">
        <Label for="name">Full Name</Label>
        <Input
          id="name"
          type="text"
          placeholder="John Doe"
          v-model="form.name"
          required
        />
      </div>

      <!-- Email -->
      <div class="grid gap-2">
        <Label for="email">Email</Label>
        <Input
          id="email"
          type="email"
          placeholder="m@example.com"
          v-model="form.email"
          required
        />
      </div>

      <!-- Password -->
      <div class="grid gap-2">
        <Label for="password">Password</Label>
        <Input
          id="password"
          type="password"
          v-model="form.password"
          required
        />
      </div>

      <!-- Confirm Password -->
      <div class="grid gap-2">
        <Label for="confirmPassword">Confirm Password</Label>
        <Input
          id="confirmPassword"
          type="password"
          v-model="form.confirmPassword"
          required
        />
      </div>
    </CardContent>

    <CardFooter>
      <Button class="w-full" @click="handleSignup">
        Sign Up
      </Button>
    </CardFooter>

    <div class="mt-4 text-center text-sm">
      Already have an account?
      <a href="/login" class="underline underline-offset-4">Log in</a>
    </div>
  </Card>
</template>

<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import { useSessionManagerStore } from '@/store/sessionManager';

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

const router = useRouter();
const sessionManager = useSessionManagerStore();

const form = ref({
  name: "",
  email: "",
  password: "",
  confirmPassword: "",
});

const handleSignup = async () => {
  if (form.value.password !== form.value.confirmPassword) {
    alert("Passwords do not match!");
    return;
  }

  try {
    await sessionManager.registerUser({
      user: {
        name: form.value.name,
        email: form.value.email,
        password: form.value.password,
        password_confirmation: form.value.confirmPassword,
      },
    });
    if (sessionManager.isAdmin) {
      router.push("/admin");
    } else {
      router.push("/events");
    }
  } catch (error) {
    console.error("Failed to sign up:", error);
    alert("Signup failed. Please try again.");
  }
};

</script>