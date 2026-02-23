ARG BUILD_FROM
FROM ${BUILD_FROM}

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Install requirements for add-on
RUN apt-get update && apt-get install -y --no-install-recommends \
    jq \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download RustBerry PoE Monitor
RUN \
    if [ "${BUILD_ARCH}" = "aarch64" ]; then \
        BINARY_NAME="rustberry-poe-monitor-aarch64"; \
    elif [ "${BUILD_ARCH}" = "armv7" ]; then \
        BINARY_NAME="rustberry-poe-monitor-armv7l"; \
    else \
        echo "Unsupported architecture: ${BUILD_ARCH}"; \
        exit 1; \
    fi \
    && echo "Downloading ${BINARY_NAME}..." \
    && curl -L -o /usr/local/bin/rustberry-poe-monitor \
        "https://github.com/jackra1n/RustBerry-PoE-Monitor/releases/download/1.2.0/${BINARY_NAME}" \
    && chmod +x /usr/local/bin/rustberry-poe-monitor

# Ensure HOME is set for the binary to find its config
ENV HOME=/root

# Copy run script
COPY run.sh /run.sh
RUN chmod a+x /run.sh

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Donach <donach.cz@gmail.com>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Donach's Add-ons" \
    org.opencontainers.image.authors="Donach <donach.cz@gmail.com>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/jackra1n/RustBerry-PoE-Monitor" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/rustberry-poe-monitor/DOCS.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

CMD [ "/run.sh" ]
