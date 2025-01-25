import React, { useState, useEffect } from "react";
import { useDispatch } from "react-redux";
import axios from "axios";
import { logout } from "../redux/authSlice";
import { useNavigate } from "react-router-dom";

const Dashboard = () => {
  const [profile, setProfile] = useState({
    username: "",
    email: "",
    phone: "",
  });
  const [isEditing, setIsEditing] = useState(false);

  const dispatch = useDispatch();
  const navigate = useNavigate();

  useEffect(() => {
    // Fetch patient profile on component mount
    const fetchProfile = async () => {
      try {
        const token = localStorage.getItem("access_token");
        const response = await axios.get(
          "http://localhost:8000/api/accounts/profile/",
          {
            headers: { Authorization: `Bearer ${token}` },
          }
        );
        setProfile(response.data);
      } catch (error) {
        console.error("Failed to fetch profile", error);
        // Logout user if token is invalid
        dispatch(logout());
        navigate("/login");
      }
    };

    fetchProfile();
  }, [dispatch, navigate]);

  const handleChange = (e) => {
    setProfile({
      ...profile,
      [e.target.name]: e.target.value,
    });
  };

  const handleLogout = () => {
    dispatch(logout());
    navigate("/login");
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      // TODO: Implement profile update API call
      setIsEditing(false);
    } catch (error) {
      console.error("Profile update failed", error);
    }
  };

  return (
    <div className="max-w-md mx-auto mt-10 p-6 bg-white shadow-md rounded">
      <h2 className="text-2xl mb-4">Patient Dashboard</h2>
      {!isEditing ? (
        <div>
          <p>
            <strong>Username:</strong> {profile.username}
          </p>
          <p>
            <strong>Email:</strong> {profile.email}
          </p>
          <p>
            <strong>Phone:</strong> {profile.phone}
          </p>
          <div className="flex justify-between mt-4">
            <button
              onClick={() => setIsEditing(true)}
              className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
            >
              Edit Profile
            </button>
            <button
              onClick={handleLogout}
              className="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded"
            >
              Logout
            </button>
          </div>
        </div>
      ) : (
        <form onSubmit={handleSubmit}>
          <input
            type="text"
            name="username"
            value={profile.username}
            onChange={handleChange}
            disabled
            className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 mb-3"
          />
          <input
            type="email"
            name="email"
            value={profile.email}
            disabled
            className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 mb-3"
          />
          <input
            type="tel"
            name="phone"
            value={profile.phone}
            onChange={handleChange}
            className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 mb-3"
          />
          <div className="flex justify-between">
            <button
              type="submit"
              className="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded"
            >
              Save Changes
            </button>
            <button
              type="button"
              onClick={() => setIsEditing(false)}
              className="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded"
            >
              Cancel
            </button>
          </div>
        </form>
      )}
    </div>
  );
};

export default Dashboard;
