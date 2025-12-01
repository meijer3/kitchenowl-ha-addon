#!/usr/bin/with-contenv bashio

# Get configuration from options
JWT_SECRET=$(bashio::config 'jwt_secret')
PORT=$(bashio::config 'port')

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

bashio::log.info "Starting KitchenOwl on port ${PORT}..."
bashio::log.info "Data directory: /data"

# KitchenOwl's official image uses uWSGI which listens on port 5000
# We need to expose it on the configured port
# The official entrypoint is /usr/src/kitchenowl/entrypoint.sh
cd /usr/src/kitchenowl

# Modify the uWSGI config to use the configured port
sed -i "s/http-socket = :5000/http-socket = :${PORT}/" wsgi.ini

# Run the official entrypoint
exec ./entrypoint.sh
