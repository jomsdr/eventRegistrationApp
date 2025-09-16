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
  }),
  getters: {
    getAuthToken: (state) => state.auth_token,
    getUserID: (state) => state.user?.id,
    getUserEmail: (state) => state.user?.email,
    isLoggedIn: (state) => !!state.auth_token,
  },
  actions: {
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