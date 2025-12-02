#!/usr/bin/env bashio

# Check if bashio is available
if ! command -v bashio &> /dev/null; then
    echo "ERROR: bashio not found. This script must run in a Home Assistant add-on environment."
    exit 1
fi

# Get configuration from options
JWT_SECRET=$(bashio::config 'jwt_secret')

# Validate required options
if [ -z "$JWT_SECRET" ]; then
    bashio::log.error "JWT_SECRET is required! Please configure it in the add-on options."
    bashio::log.info "Generate one with: openssl rand -base64 32"
    exit 1
fi

# Export environment variables for KitchenOwl
export JWT_SECRET_KEY="$JWT_SECRET"
export STORAGE_PATH="/data"
export DEBUG="False"

bashio::log.info "Starting KitchenOwl..."
bashio::log.info "Data directory: /data"

# Run the official KitchenOwl entrypoint with default uWSGI arguments
# The official image uses HTTP on port 8080
cd /usr/src/kitchenowl
exec ./entrypoint.sh --ini wsgi.ini:web --gevent 200 --max-fd 1048576
