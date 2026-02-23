#!/usr/bin/with-contenv bashio
set -e

# Setup logic moved to /etc/cont-init.d/00-setup.sh to prevent race condition with s6 services.
bashio::log.info "Container initialization complete."

# The CMD needs to run, but s6 manages the daemon. We can just sleep or exit.
# Usually, CMD is for the main application. If the main app is a service, CMD is often ignored or used for legacy compatibility.
# In this case, we just log and exit, letting s6 keep the container running due to services.
bashio::log.info "Handing over to s6 supervision."
exec sleep infinity
