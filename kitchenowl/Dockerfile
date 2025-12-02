FROM tombursch/kitchenowl:latest

# Install Home Assistant add-on dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install bashio for Home Assistant add-on configuration support
RUN curl -J -L -o /tmp/bashio.tar.gz \
    "https://github.com/hassio-addons/bashio/archive/v0.16.2.tar.gz" \
    && mkdir /tmp/bashio \
    && tar zxvf /tmp/bashio.tar.gz --strip 1 -C /tmp/bashio \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && rm -rf /tmp/bashio /tmp/bashio.tar.gz

# Copy custom run script that reads Home Assistant configuration
COPY run.sh /
RUN chmod a+x /run.sh

WORKDIR /usr/src/kitchenowl
ENTRYPOINT ["/run.sh"]
