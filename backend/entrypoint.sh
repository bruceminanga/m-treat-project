#!/bin/sh
set -e

echo "Waiting for PostgreSQL database..."
while ! nc -z db 5432; do
    sleep 0.5
done
echo "PostgreSQL started!"

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate --noinput

# Execute the container's main command (e.g. runserver)
exec "$@"
