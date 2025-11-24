# Creating a Home Assistant Add-on for KitchenOwl

This guide explains how to create an all-in-one Home Assistant Add-on that runs KitchenOwl, a self-hosted grocery list and recipe manager.

## About KitchenOwl

KitchenOwl is a self-hosted application that provides:
- Real-time shopping list synchronization across multiple users
- Recipe management and sharing
- Meal planning functionality
- Expense tracking for households
- Mobile, web, and desktop applications

**Technology Stack:**
- Backend: Flask (Python)
- Frontend: Flutter (Dart) compiled to web
- All-in-one container running both services

## Home Assistant Add-on Structure

A Home Assistant Add-on requires these core files:

1. **config.yaml** - Add-on metadata and configuration
2. **Dockerfile** - Container image specification
3. **run.sh** - Startup script
4. **nginx.conf** - Web server configuration

### Important Notes
- Use UNIX-like line breaks (LF), NOT DOS/Windows (CRLF)
- Supported architectures: aarch64, amd64, armv7
- All services run in a single container (all-in-one approach)

## Implementation

### File 1: config.yaml

```yaml
name: KitchenOwl
version: "1.0.0"
slug: kitchenowl
description: Self-hosted grocery list and recipe manager
url: https://github.com/TomBursch/kitchenowl
arch:
  - aarch64
  - amd64
  - armv7
init: false
startup: services
boot: auto

# Port mappings
ports:
  8080/tcp: 8080

# Port descriptions for UI
ports_description:
  8080/tcp: Web interface

# User-configurable options
options:
  jwt_secret: ""

# Schema for validating options
schema:
  jwt_secret: password

# Image configuration
image: ghcr.io/{arch}-kitchenowl

# Web UI
webui: http://[HOST]:8080
```

### Configuration Fields Explained

- **name**: Display name in Home Assistant
- **version**: Semantic version (increment to trigger updates)
- **slug**: Unique identifier (lowercase, no spaces)
- **arch**: Supported CPU architectures
- **startup**: Set to `services` for long-running applications
- **boot**: `auto` means start on Home Assistant boot
- **ports**: Map container ports to host ports
- **options**: User-configurable settings
- **schema**: Data type validation (password = required secret string)
- **webui**: Direct link to web interface

### File 2: Dockerfile

```dockerfile
ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install base dependencies
RUN apk add --no-cache \
    nginx \
    python3 \
    py3-pip \
    py3-flask \
    py3-flask-cors \
    py3-sqlalchemy \
    py3-bcrypt \
    py3-jwt \
    curl

# Create app directories
RUN mkdir -p /app/backend /app/frontend /data

# Download and setup KitchenOwl backend
WORKDIR /app/backend
RUN curl -L https://github.com/TomBursch/kitchenowl/archive/refs/heads/main.tar.gz | tar xz --strip-components=2 kitchenowl-main/backend
RUN pip3 install --no-cache-dir -r requirements.txt

# Download and setup KitchenOwl frontend
WORKDIR /app/frontend
RUN curl -L https://github.com/TomBursch/kitchenowl/archive/refs/heads/main.tar.gz | tar xz --strip-components=2 kitchenowl-main/kitchenowl_web && \
    if [ -d "build" ]; then mv build/* . && rm -rf build; fi

# Configure nginx
COPY nginx.conf /etc/nginx/http.d/default.conf

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

WORKDIR /app
CMD ["/run.sh"]
```

### File 3: nginx.conf

```nginx
server {
    listen 8080;
    server_name _;

    # Frontend static files
    location / {
        root /app/frontend;
        try_files $uri $uri/ /index.html;
    }

    # Backend API proxy
    location /api/ {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### File 4: run.sh

```bash
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
```

## How It Works

The all-in-one approach runs both services in a single container:

1. **Backend (Flask)**: Runs on port 5000 internally
2. **Frontend (Static files)**: Served by nginx on port 8080
3. **Nginx**: Acts as reverse proxy, routing `/api/*` to backend and serving frontend files for all other requests
4. **Data persistence**: Uses `/data` directory for database and uploads

### Architecture Flow

```
User Browser → Port 8080 (nginx)
                    ├─→ / (frontend static files)
                    └─→ /api/* → localhost:5000 (backend)
```

## Repository Structure

Your add-on directory should look like this:

```
kitchenowl-ha-addon/
├── config.yaml
├── Dockerfile
├── nginx.conf
├── run.sh
├── README.md (optional)
├── CHANGELOG.md (optional)
├── DOCS.md (optional - user documentation)
├── icon.png (optional - 256x256px)
└── logo.png (optional - 256x256px)
```

## Testing Locally

### Method 1: Local Add-on Store

1. **Copy files to Home Assistant:**
   ```bash
   # On your Home Assistant host
   mkdir -p /addons/kitchenowl
   # Copy all files to this directory
   ```

2. **Add local repository:**
   - Settings → Add-ons → Add-on Store
   - Click three dots (top right) → Repositories
   - Add: `/addons`

3. **Install and test:**
   - Click "Check for updates"
   - Find KitchenOwl in local add-ons
   - Click Install

### Method 2: Developer Mode

1. **Enable developer mode:**
   - Settings → Add-ons → Add-on Store
   - Enable "Advanced Mode" in user profile

2. **Use local development:**
   - Place add-on in `/addons/local/kitchenowl/`
   - Reload add-on store

### Checking Logs

- **Supervisor logs**: For validation errors in config.yaml
- **Add-on logs**: For runtime errors (Backend/Nginx)
- Look for: "JWT_SECRET is required" or Flask errors

## User Configuration

After installing, users must configure:

### JWT Secret (Required)

A secure random string for authentication tokens.

**Generate with:**
```bash
openssl rand -base64 32
```

**Configure in:**
- Add-on Configuration tab
- Enter the generated secret in the `jwt_secret` field
- Save and restart the add-on

## Publishing

### Option 1: GitHub Repository

1. **Create repository:**
   ```bash
   git init
   git add .
   git commit -m "Initial KitchenOwl add-on"
   git remote add origin https://github.com/yourusername/kitchenowl-ha-addon.git
   git push -u origin main
   ```

2. **Users add your repository:**
   - Settings → Add-ons → Add-on Store → Repositories
   - Add: `https://github.com/yourusername/kitchenowl-ha-addon`

### Option 2: Build and Push Images

```bash
# Build for multiple architectures
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t ghcr.io/yourusername/kitchenowl-ha-addon:latest \
  --push .
```

Update `config.yaml` with your image URL:
```yaml
image: ghcr.io/yourusername/kitchenowl-ha-addon
```

## Advanced Configuration

### Environment Variables

The backend uses:
- `JWT_SECRET_KEY`: Required for authentication
- `DATA_DIR`: Data storage location (defaults to `/data`)
- Additional variables in KitchenOwl's Flask app

### Persistent Storage

Data is stored in `/data` (managed by Home Assistant):
- SQLite database
- User uploads (recipe images, etc.)
- Application configuration

Access location: `/usr/share/hassio/addons/data/<slug>/`

### Networking

- **Internal**: Backend on `127.0.0.1:5000`
- **External**: Web interface on `[HOST]:8080`
- **No host networking**: Container uses bridge network

### Adding Ingress (Optional)

For embedding in Home Assistant UI, add to `config.yaml`:

```yaml
ingress: true
ingress_port: 8080
panel_icon: mdi:food-apple
```

Then users access via Sidebar → KitchenOwl

## Troubleshooting

### Add-on doesn't appear
- Check YAML syntax: `yamllint config.yaml`
- Verify line endings are LF (not CRLF)
- Check supervisor logs
- Ensure architecture is supported

### Container fails to start
- **No JWT_SECRET**: Configure in add-on options
- **Port conflict**: Another service using 8080
- **Missing dependencies**: Check Dockerfile build logs

### Backend errors
- Check add-on logs for Flask errors
- Verify `/data` is writable
- Ensure Python dependencies installed correctly

### Frontend doesn't load
- Check nginx logs in add-on logs
- Verify frontend files extracted correctly
- Test backend API: `curl http://localhost:5000/api/health`

### Database issues
- Check `/data` directory permissions
- Verify SQLite database created
- Review backend logs for database errors

## Version Management

To release updates:

1. **Make changes** to code/config
2. **Increment version** in config.yaml:
   ```yaml
   version: "1.0.1"  # Bug fixes
   version: "1.1.0"  # New features
   version: "2.0.0"  # Breaking changes
   ```
3. **Update CHANGELOG.md**
4. **Commit and push**
5. Users see update notification in Home Assistant

## Best Practices

### Security
- Never hardcode secrets
- Always require JWT_SECRET configuration
- Use strong random strings (32+ characters)
- Validate user input in add-on options
- Keep dependencies updated

### User Experience
- Provide clear DOCS.md for users
- Include helpful error messages
- Set webui link for easy access
- Add icon.png and logo.png
- Write detailed README.md

### Maintenance
- Use semantic versioning
- Document all changes in CHANGELOG.md
- Test on all supported architectures
- Monitor KitchenOwl updates
- Respond to user issues

### Performance
- Minimize Dockerfile layers
- Use Alpine packages when available
- Don't install unnecessary dependencies
- Use multi-stage builds if needed
- Cache pip/apk downloads

## Resources

- [Home Assistant Add-on Documentation](https://developers.home-assistant.io/docs/add-ons/)
- [KitchenOwl GitHub Repository](https://github.com/TomBursch/kitchenowl)
- [Home Assistant Add-on Example](https://github.com/home-assistant/addons-example)
- [Home Assistant Community Add-ons](https://github.com/hassio-addons/repository)
- [Bashio Documentation](https://github.com/hassio-addons/bashio)

## Next Steps

1. ✅ Create all required files (config.yaml, Dockerfile, nginx.conf, run.sh)
2. Test locally on your Home Assistant instance
3. Generate JWT secret for testing
4. Check add-on logs for any errors
5. Access web interface and verify functionality
6. Create README.md and DOCS.md for users
7. Add icon.png and logo.png
8. Publish to GitHub
9. Share with community
10. Monitor and maintain

## Support

For issues with:
- **This add-on**: Create issue in your repository
- **KitchenOwl app**: See [KitchenOwl GitHub](https://github.com/TomBursch/kitchenowl)
- **Home Assistant**: See [HA Community](https://community.home-assistant.io/)
