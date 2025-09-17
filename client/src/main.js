import { createApp } from 'vue';
import { createPinia } from 'pinia';
import './style.css';
import App from './App.vue';
import router from './routes';
import axios from 'axios';

import { useSessionManagerStore } from '@/store/sessionManager';

axios.interceptors.response.use(
  response => response,
  error => {
    if (!error.response) {
      alert('Server is unavailable or restarting. Please try again in a moment.');
    }
    return Promise.reject(error);
  }
);

const app = createApp(App);
const pinia = createPinia();

app.use(router);
app.use(pinia);

// Restore auth token if present
const sessionManager = useSessionManagerStore();
sessionManager.hydrate()
const localAuthToken = localStorage.getItem('auth_token');
if (localAuthToken && localAuthToken !== 'undefined') {
  sessionManager.auth_token = localAuthToken;
  axios.defaults.headers.common['Authorization'] = localAuthToken;
}

app.mount('#app');