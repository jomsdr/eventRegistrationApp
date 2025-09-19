# Event Registration App

This project is a **full-stack web application** for managing event registrations.  
It uses **Ruby on Rails** as the backend (API-only) and **Vue.js** as the frontend.  
The backend handles authentication, user management, and API endpoints, while the frontend provides a responsive UI.

---

## **Tech Stack**
- **Frontend:** Vue 3, Vite, Axios, TailwindCSS (with ShadCN Vue UI components)
- **Backend:** Ruby on Rails 8 (API mode), PostgreSQL, JWT authentication
- **Authentication:** Devise with JWT
- **Deployment:**  
  - Backend: Render 
  - Frontend: Vercel 

---

## **Setup Instructions**

### **1. Clone the repository**
```bash
git clone https://github.com/your-username/eventRegistrationApp.git
cd eventRegistrationApp
```

## **Backend (Rails API) Setup**

Make sure you have **Ruby 3.4+** and **Rails 8+** installed.

### **Steps:**

#### **1. Install dependencies**
```bash
bundle install
```

#### **2. Setup the database**

```bash
rails db:create db:migrate
```

#### **3. Setup the database**
```bash
rails s
```

## **Frontend (Vue) Setup**

Go to the frontend folder:
```bash
cd client
```

### **Steps:**

#### **1. Install dependencies**
```bash
npm install
```

#### **2. Create a .env file**

```bash
VITE_API_URL=http://localhost:3000
```

#### **3. Run the frontend**
```bash
npm run dev
```
