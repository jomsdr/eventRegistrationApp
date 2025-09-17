<template>
  <Card class="w-full max-w-sm">
    <CardHeader>
      <CardTitle class="text-2xl">Edit Registration</CardTitle>
      <CardDescription>Edit attendee details below.</CardDescription>
    </CardHeader>
    <CardContent class="grid gap-4">
      <div class="grid gap-2">
        <Label for="name">Attendee Name</Label>
        <Input id="name" v-model="form.name" type="text" placeholder="Name" required />
      </div>
      <div class="grid gap-2">
        <Label for="email">Email</Label>
        <Input id="email" v-model="form.email" type="email" placeholder="foo@email.com" required />
      </div>
      <div v-if="error" class="text-red-500 text-sm mb-2">{{ error }}</div>
    </CardContent>
    <CardFooter class="flex gap-2 justify-end">
      <Button variant="outline" @click="onCancel" type="button">Cancel</Button>
      <Button type="submit" @click="onSubmit">Save</Button>
    </CardFooter>
  </Card>
</template>

<script setup>
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { ref, watch, defineProps, defineEmits } from 'vue';

const props = defineProps({
  modelValue: Object,
  error: String
});
const emit = defineEmits(['update:modelValue', 'submit', 'cancel']);

const form = ref({ name: '', email: '' });

watch(() => props.modelValue, (val) => {
  if (val) form.value = { ...val };
}, { immediate: true });

function onSubmit(e) {
  e.preventDefault();
  emit('submit', { ...form.value });
}
function onCancel() {
  emit('cancel');
}
</script>
