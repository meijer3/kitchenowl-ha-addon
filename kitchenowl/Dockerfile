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
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt

# Download and setup KitchenOwl frontend
WORKDIR /app/frontend
RUN curl -L https://github.com/TomBursch/kitchenowl/archive/refs/heads/main.tar.gz | tar xz --strip-components=2 kitchenowl-main/kitchenowl_web && \
    if [ -d "build" ]; then mv build/* . && rm -rf build; fi

# Copy run script (nginx config will be generated at runtime)
COPY run.sh /
RUN chmod a+x /run.sh

WORKDIR /app
CMD ["/run.sh"]
