#!/usr/bin/with-contenv bashio
set -e

# Regex to match Debian-style UUID
uuid_regex='^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89ABab][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$'

# Pull from add-on options
AGENT_ID=$(bashio::config 'agent_id')
SECRET_KEY=$(bashio::config 'secret_key')

# Validate
if ! [[ "$AGENT_ID" =~ $uuid_regex ]]; then
  bashio::log.fatal "Agent ID ($AGENT_ID) has invalid format"
fi
if ! [[ "$SECRET_KEY" =~ $uuid_regex ]]; then
  bashio::log.fatal "Secret key ($SECRET_KEY) has invalid format"
fi

# Ensure config directory
mkdir -p /etc/braiins-manager-agent

# Write out daemon.yaml (overwriting any existing)
if [ -n "$AGENT_ID" ]; then
  cat > /etc/braiins-manager-agent/daemon.yaml <<EOF
agent_id: $AGENT_ID
secret_key: $SECRET_KEY
EOF
fi
echo "daemon.yaml:"
cat /etc/braiins-manager-agent/daemon.yaml

# Update Braiins Manager Agent binary
bashio::log.info "Checking for Braiins Manager Agent updates..."

# Architecture mapping
case "$(bashio::info.arch)" in
    "amd64")
        ARCH="x86_64"
        ;;
    "aarch64")
        ARCH="aarch64"
        ;;
    *)
        bashio::log.warning "Unsupported architecture for updates: $(bashio::info.arch)"
        ARCH=""
        ;;
esac

if [ -n "${ARCH}" ]; then
    LATEST_VERSION=$(curl -s https://downloads.braiins.com/braiins-manager-agent/ | grep -oE 'assets/[0-9.]+' | cut -d/ -f2 | sort -V | tail -n 1)

    if [ -n "${LATEST_VERSION}" ]; then
        bashio::log.info "Latest version found: ${LATEST_VERSION}"

        # Check installed version to avoid unnecessary downloads
        # The updated binary is stored in /data/ (persistent) so it survives container rebuilds
        INSTALLED_VERSION=""
        VERSION_FILE="/data/.bma-version"
        if [ -f "${VERSION_FILE}" ] && [ -f "/data/bma-daemon" ]; then
            INSTALLED_VERSION=$(cat "${VERSION_FILE}")
        fi

        if [ "${INSTALLED_VERSION}" = "${LATEST_VERSION}" ]; then
            bashio::log.info "Already running latest version ${INSTALLED_VERSION}, skipping update."
        else
            if [ -n "${INSTALLED_VERSION}" ]; then
                bashio::log.info "Updating from ${INSTALLED_VERSION} to ${LATEST_VERSION}..."
            else
                bashio::log.info "Installing version ${LATEST_VERSION}..."
            fi

        DOWNLOAD_URL="https://downloads.braiins.com/braiins-manager-agent/assets/${LATEST_VERSION}/braiins-manager-agent-linux-${ARCH}.deb"

        # Create temp dir
        TEMP_DIR=$(mktemp -d)
        cd "${TEMP_DIR}"

        bashio::log.info "Downloading update from ${DOWNLOAD_URL}..."
        if curl -L -f --connect-timeout 30 --max-time 300 -o "agent.deb" "${DOWNLOAD_URL}"; then
            bashio::log.info "Download successful, extracting..."

            # Extract deb package
            if ar x agent.deb; then
                # Extract data archive (usually data.tar.xz or data.tar.gz)
                DATA_TAR=$(find . -name "data.tar*" | head -1)
                if [ -n "${DATA_TAR}" ]; then
                    if tar -xf "${DATA_TAR}"; then
                        # Find the binary
                        NEW_BINARY=$(find . -name "bma-daemon" -type f | head -1)
                        if [ -n "${NEW_BINARY}" ]; then
                            bashio::log.info "Replacing binary..."
                            cp "${NEW_BINARY}" /data/bma-daemon
                            chmod +x /data/bma-daemon
                            echo "${LATEST_VERSION}" > "${VERSION_FILE}"
                            bashio::log.info "Update complete."
                        else
                            bashio::log.error "Could not find bma-daemon binary in extracted package."
                        fi
                    else
                        bashio::log.error "Failed to extract ${DATA_TAR}"
                    fi
                else
                    bashio::log.error "Could not find data.tar archive in deb package."
                fi
            else
                bashio::log.error "Failed to extract deb package."
            fi
        else
            bashio::log.warning "Failed to download update."
        fi

        # Cleanup
        cd /
        rm -rf "${TEMP_DIR}"
        fi
    else
        bashio::log.warning "Failed to fetch latest version info."
    fi

    # Verify binary exists (required since binaries are downloaded, not bundled)
    if [ ! -f "/data/bma-daemon" ]; then
        bashio::log.fatal "No bma-daemon binary available. Download may have failed."
        exit 1
    fi
fi
