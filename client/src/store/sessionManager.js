import { defineStore } from 'pinia';
import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL;

export const useSessionManagerStore = defineStore('sessionManager', {
  state: () => ({
    auth_token: null,
    user: {
      id: null,
      email: null,
      username: null,
    },
    hydrated: false,
  }),
  getters: {
    getAuthToken: (state) => state.auth_token,
    getUserID: (state) => state.user?.id,
    getUserEmail: (state) => state.user?.email,
    getUserRole: (state) => state.user?.role,
    isAdmin: (state) => state.user?.role === 'admin',
    isLoggedIn: (state) => !!state.auth_token,
  },
  actions: {
    async hydrate() {
      // Hydrate auth_token from localStorage
      const token = localStorage.getItem('auth_token');
      if (token) {
        this.auth_token = token;
        axios.defaults.headers.common['Authorization'] = token;
      }
      // Fetch user profile if token exists and user is not set
      if (token && (!this.user || !this.user.email)) {
        try {
          const res = await axios.get(`${API_URL}/member-data`, {
            headers: { Authorization: token }
          });
          this.user = res.data.user;
        } catch (e) {
          this.resetUserInfo();
        }
      }
      this.hydrated = true;
    },
    async registerUser(payload) {
      const response = await axios.post(`${API_URL}/users`, payload);
      this.setUserInfo(response);
      return response;
    },
    async loginUser(payload) {
      const response = await axios.post(`${API_URL}/users/sign_in`, payload);
      this.setUserInfo(response);
      return response;
    },
    async logoutUser() {
      await axios.delete(`${API_URL}/users/sign_out`, {
        headers: { 
            Authorization: this.auth_token,
            Accept: 'application/json'},
      });
      this.resetUserInfo();
    },
    // async loginUserWithToken(payload) {
    //   const config = {
    //     headers: {
    //       Authorization: payload.auth_token,
    //     },
    //   };
    //   const response = await axios.get(`${API_URL}/member-data`, config);
    //   this.setUserInfoFromToken(response);
    //   return response;
    // },
    setUserInfo(data) {
      this.user = data.data.user;
      this.auth_token = data.headers.authorization;
      axios.defaults.headers.common['Authorization'] = this.auth_token;
      localStorage.setItem('auth_token', this.auth_token);
    },
    setUserInfoFromToken(data) {
      this.user = data.data.user;
      this.auth_token = localStorage.getItem('auth_token');
      axios.defaults.headers.common['Authorization'] = this.auth_token;
    },
    resetUserInfo() {
      this.user = { id: null, email: null, username: null };
      this.auth_token = null;
      axios.defaults.headers.common['Authorization'] = null;
      localStorage.removeItem('auth_token');
    },
  },
});

