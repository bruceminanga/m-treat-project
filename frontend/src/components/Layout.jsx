import React from "react";

const Layout = ({ children }) => {
  return (
    <div className="min-h-screen w-full bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
      {/* You can customize the background styles here */}
      <div className="w-full max-w-4xl">{children}</div>
    </div>
  );
};

export default Layout;
