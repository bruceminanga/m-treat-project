import React, { useState } from "react";
import { useDispatch } from "react-redux";
import { useNavigate, Link } from "react-router-dom";
import { registerUser } from "../redux/authSlice";

const Register = () => {
  // 1. FORM STATE
  // Stores all user details matching the Django serializer fields
  const [formData, setFormData] = useState({
    username: "",
    email: "",
    phone: "",
    password: "",
    confirm_password: "",
  });

  // 2. UI & ACCESSIBILITY STATES
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [message, setMessage] = useState({ text: "", type: "" });

  const dispatch = useDispatch();
  const navigate = useNavigate();

  // 3. INPUT CHANGE HANDLER
  const handleChange = (e) => {
    // Clear alerts as soon as the user starts correcting their input
    if (message.text) setMessage({ text: "", type: "" });

    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  // 4. FORM SUBMISSION & VALIDATION
  const handleSubmit = async (e) => {
    e.preventDefault();

    // Client-side validation: Check password match before calling the API
    if (formData.password !== formData.confirm_password) {
      setMessage({
        text: "Passwords do not match. Please re-enter them.",
        type: "error",
      });
      return;
    }

    // Optional: Check minimum length requirement
    if (formData.password.length < 8) {
      setMessage({
        text: "Password must be at least 8 characters long.",
        type: "error",
      });
      return;
    }

    setIsLoading(true);

    try {
      // Dispatch registration payload to Django backend
      await dispatch(registerUser(formData)).unwrap();

      setMessage({
        text: "Account registered successfully! Redirecting to login...",
        type: "success",
      });

      // Brief delay to let the user see the success confirmation
      setTimeout(() => {
        navigate("/login");
      }, 1500);
    } catch (error) {
      console.error("Registration error:", error);

      // Django REST Framework returns errors as an object, e.g.:
      // { username: ["A user with that username already exists."], password: [...] }
      let errorMessage = "Registration failed. Please check your information.";

      if (typeof error === "object" && error !== null) {
        const firstKey = Object.keys(error)[0];
        if (firstKey) {
          const detail = error[firstKey];
          errorMessage = Array.isArray(detail)
            ? `${firstKey.toUpperCase()}: ${detail[0]}`
            : detail;
        }
      } else if (typeof error === "string") {
        errorMessage = error;
      }

      setMessage({
        text: errorMessage,
        type: "error",
      });
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-6">

        {/* BRANDING HEADER */}
        <div className="text-center">
          {/* Medical Cross Logo */}
          <div className="mx-auto h-12 w-12 bg-blue-600 rounded-xl flex items-center justify-center shadow-md shadow-blue-500/20 mb-3">
            <svg className="h-7 w-7 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 4v16m8-8H4" />
            </svg>
          </div>
          <h2 className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
            Create Patient Account
          </h2>
          <p className="mt-1 text-sm text-slate-500">
            Join M-treat to manage your health and treatments
          </p>
        </div>

        {/* REGISTRATION CARD */}
        <div className="bg-white py-8 px-6 shadow-xl shadow-slate-200/60 rounded-2xl border border-slate-100 sm:px-10">

          {/* DYNAMIC ALERT BANNER */}
          {message.text && (
            <div
              className={`mb-5 p-3.5 rounded-xl text-sm flex items-start gap-2.5 transition-all ${message.type === "success"
                  ? "bg-emerald-50 text-emerald-800 border border-emerald-200"
                  : "bg-rose-50 text-rose-800 border border-rose-200"
                }`}
              role="alert"
            >
              <span className="font-medium">{message.text}</span>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">

            {/* USERNAME */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wider mb-1">
                Username *
              </label>
              <input
                type="text"
                name="username"
                placeholder="Choose a username"
                value={formData.username}
                onChange={handleChange}
                required
                disabled={isLoading}
                className="w-full px-3.5 py-2 border border-slate-200 rounded-lg text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 transition text-sm disabled:bg-slate-50"
              />
            </div>

            {/* EMAIL */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wider mb-1">
                Email Address *
              </label>
              <input
                type="email"
                name="email"
                placeholder="name@example.com"
                value={formData.email}
                onChange={handleChange}
                required
                disabled={isLoading}
                className="w-full px-3.5 py-2 border border-slate-200 rounded-lg text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 transition text-sm disabled:bg-slate-50"
              />
            </div>

            {/* PHONE NUMBER (OPTIONAL) */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wider mb-1">
                Phone Number <span className="text-slate-400 font-normal lowercase">(optional)</span>
              </label>
              <input
                type="tel"
                name="phone"
                placeholder="+254 700 000000"
                value={formData.phone}
                onChange={handleChange}
                disabled={isLoading}
                className="w-full px-3.5 py-2 border border-slate-200 rounded-lg text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 transition text-sm disabled:bg-slate-50"
              />
            </div>

            {/* PASSWORD */}
            <div>
              <div className="flex justify-between items-center mb-1">
                <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wider">
                  Password *
                </label>
                {/* Show / Hide Toggle Button */}
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="text-xs text-blue-600 hover:text-blue-500 font-medium focus:outline-none"
                  tabIndex={-1}
                >
                  {showPassword ? "Hide" : "Show"}
                </button>
              </div>
              <input
                type={showPassword ? "text" : "password"}
                name="password"
                placeholder="Minimum 8 characters"
                value={formData.password}
                onChange={handleChange}
                required
                disabled={isLoading}
                className="w-full px-3.5 py-2 border border-slate-200 rounded-lg text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 transition text-sm disabled:bg-slate-50"
              />
            </div>

            {/* CONFIRM PASSWORD */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wider mb-1">
                Confirm Password *
              </label>
              <input
                type={showPassword ? "text" : "password"}
                name="confirm_password"
                placeholder="Re-enter password"
                value={formData.confirm_password}
                onChange={handleChange}
                required
                disabled={isLoading}
                className="w-full px-3.5 py-2 border border-slate-200 rounded-lg text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 transition text-sm disabled:bg-slate-50"
              />
            </div>

            {/* SUBMIT BUTTON */}
            <button
              type="submit"
              disabled={isLoading}
              className="w-full mt-2 flex justify-center items-center py-2.5 px-4 rounded-lg text-sm font-semibold text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition duration-150 disabled:opacity-60 disabled:cursor-not-allowed shadow-sm"
            >
              {isLoading ? (
                <>
                  <svg className="animate-spin -ml-1 mr-2.5 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Creating Account...
                </>
              ) : (
                "Create Account"
              )}
            </button>
          </form>

          {/* FOOTER: BACK TO LOGIN */}
          <div className="mt-6 pt-5 border-t border-slate-100 text-center">
            <p className="text-sm text-slate-600">
              Already registered?{" "}
              <Link
                to="/login"
                className="font-semibold text-blue-600 hover:text-blue-500 transition"
              >
                Sign In
              </Link>
            </p>
          </div>

        </div>
      </div>
    </div>
  );
};

export default Register;