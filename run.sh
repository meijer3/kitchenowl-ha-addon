#!/usr/bin/with-contenv bashio

# Get configuration from options
JWT_SECRET=$(bashio::config 'jwt_secret')

# Validate required options
if [ -z "$JWT_SECRET" ]; then
    bashio::log.error "JWT_SECRET is required! Please configure it in the add-on options."
    bashio::log.info "Generate one with: openssl rand -base64 32"
    exit 1
fi

# Export environment variables for backend
export JWT_SECRET_KEY="$JWT_SECRET"
export DATA_DIR="/data"

bashio::log.info "Starting KitchenOwl backend..."

# Start backend in background
cd /app/backend
python3 -m flask run --host=0.0.0.0 --port=5000 &
BACKEND_PID=$!

bashio::log.info "Backend started with PID $BACKEND_PID"

# Wait for backend to be ready
sleep 3

bashio::log.info "Starting nginx web server..."

# Start nginx in foreground
nginx -g 'daemon off;' &
NGINX_PID=$!

bashio::log.info "Nginx started with PID $NGINX_PID"
bashio::log.info "KitchenOwl is running on port 8080"

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?
