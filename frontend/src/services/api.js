import axios from 'axios';

// 1. BASE URL CONFIGURATION
// We use a leading slash ('/api/accounts/') so Axios always requests from the 
// root domain, avoiding accidental nested URLs like '/dashboard/api/accounts/'.
// Note: If React runs on a different port (e.g., 3000) than Django (8000) 
// without a proxy, use: 'http://localhost:8000/api/accounts/'
const BASE_URL = '/api/accounts/';

// 2. AXIOS INSTANCE
// This creates a dedicated HTTP client with default headers.
// Every request made with 'api' will automatically send and expect JSON.
const api = axios.create({
  baseURL: BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 3. REQUEST INTERCEPTOR (Automating the Bearer Token)
// Instead of manually writing "-H 'Authorization: Bearer ...'" in curl every time,
// this interceptor intercepts EVERY outgoing request, checks if an access token 
// exists in localStorage, and automatically attaches it to the request header.
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('access_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// 4. API FUNCTIONS (The Menu of Available Actions)
// These map 1-to-1 with the routes you defined in Django's accounts/urls.py.
export const authAPI = {
  // POST /api/accounts/register/
  // Sends username, email, password to create a new patient account
  register: (userData) => api.post('register/', userData),

  // POST /api/accounts/login/
  // Sends credentials; receives { access: "...", refresh: "..." }
  login: (credentials) => api.post('login/', credentials),

  // GET /api/accounts/profile/
  // Fetches the currently authenticated user's profile (like you tested with curl)
  getProfile: () => api.get('profile/'),

  // PATCH /api/accounts/profile/update/
  // Partially updates the user's information (email, phone, etc.)
  updateProfile: (profileData) => api.patch('profile/update/', profileData),

  // POST /api/accounts/token/refresh/
  // Sends the stored refresh token to get a new access token when the old one expires
  refreshToken: (refreshToken) => api.post('token/refresh/', { refresh: refreshToken }),
};

export default api;