import { createRouter, createWebHistory } from 'vue-router';
import LoginView from "@/views/LoginView.vue";
import SignupView from "@/views/SignupView.vue";
import EventView from '@/views/EventView.vue';
import EventsListView from '@/views/EventsListView.vue';
import EventShowView from '@/views/EventShowView.vue';
import AdminDashboardView from '@/views/AdminDashboardView.vue';
import RegistrationEditView from '@/views/RegistrationEditView.vue';
import { useSessionManagerStore } from '@/store/sessionManager';
import NotFoundView from '@/views/NotFoundView.vue';
import NotAuthorizedView from '@/views/NotAuthorizedView.vue';
// Placeholder imports for future admin management views
// import AdminEventManagementView from '@/views/AdminEventManagementView.vue';
// import AdminRegistrationManagementView from '@/views/AdminRegistrationManagementView.vue';

const routes = [
  { path: "/login", name: "Login", component: LoginView },
  { path: "/signup", name: "Signup", component: SignupView },
  { path: "/events", name: "EventsList", component: EventsListView },
  { path: "/events/new", name: "NewEvent", component: EventView },
  {
    path: "/events/:id(\\d+)",
    name: "EventShow",
    component: EventShowView,
    props: true,
  },
  {
    path: "/events/:eventId/registrations/:registrationId/edit",
    name: "RegistrationEdit",
    component: RegistrationEditView,
    props: true,
  },
  {
    path: "/events/:id/edit",
    name: "EventEdit",
    component: EventView,
    props: route => ({ mode: "edit", eventId: route.params.id }),
  },
  { path: "/admin", name: "AdminDashboard", component: AdminDashboardView },
  // Future admin management routes
  // { path: "/admin/events", name: "AdminEventManagement", component: AdminEventManagementView },
  // { path: "/admin/registrations", name: "AdminRegistrationManagement", component: AdminRegistrationManagementView },
  { path: "/not-authorized", name: "NotAuthorized", component: NotAuthorizedView },
  { path: "/:pathMatch(.*)*", name: "NotFound", component: NotFoundView },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// Navigation guard for role-based access and redirect logic
router.beforeEach(async (to, from, next) => {
  const sessionManager = useSessionManagerStore();

  // Wait for hydration if not done yet
  if (!sessionManager.hydrated) {
    await sessionManager.hydrate();
  }

  // Wait for user info to be loaded if token exists but user is not yet set
  if (
    sessionManager.auth_token &&
    (!sessionManager.user || !sessionManager.user.role)
  ) {
    // Try to re-hydrate to get user info
    await sessionManager.hydrate();
  }

  const isLoggedIn = sessionManager.isLoggedIn;
  const isAdmin = sessionManager.isAdmin;

  // Home route: redirect based on role
  if (to.path === '/') {
    if (!isLoggedIn) return next('/login');
    if (isAdmin) return next('/admin');
    return next('/events');
  }

  // Public routes: login/signup
  if (["/login", "/signup"].includes(to.path)) {
    if (isLoggedIn) {
      // Already logged in, redirect to dashboard
      return next(isAdmin ? '/admin' : '/events');
    }
    return next();
  }

  // Admin routes
  if (to.path.startsWith('/admin')) {
    if (!isLoggedIn) return next('/login');
    if (!isAdmin) return next('/not-authorized');
    return next();
  }

  // User event routes
  if (to.path.startsWith('/events')) {
    if (!isLoggedIn) return next('/login');
    // Allow both users and admins to access /events routes
    return next();
  }

  // Not authorized and not found routes are always accessible
  if (["/not-authorized"].includes(to.path)) return next();

  // Fallback: allow navigation
  return next();
});

export default router;