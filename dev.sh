#!/bin/bash

# Build React
cd frontend
npm run build

# Create build directory in Django if it doesn't exist
mkdir -p ../backend/frontend/build

# Copy build files to Django directory
cp -r build/* ../backend/frontend/build/

# Go to Django directory and run server
cd ../backend
python manage.py runserver