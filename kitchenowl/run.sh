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

bashio::log.info "Configuring nginx to listen on port ${PORT}..."

# Generate nginx config with configured port
cat > /etc/nginx/http.d/default.conf <<EOF
server {
    listen ${PORT};
    server_name _;

    # Frontend static files
    location / {
        root /app/frontend;
        try_files \$uri \$uri/ /index.html;
    }

    # Backend API proxy
    location /api/ {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

bashio::log.info "Starting nginx web server..."

# Start nginx in foreground
nginx -g 'daemon off;' &
NGINX_PID=$!

bashio::log.info "Nginx started with PID $NGINX_PID"
bashio::log.info "KitchenOwl is running on port ${PORT}"

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?
