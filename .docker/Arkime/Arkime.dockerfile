# syntax=docker/dockerfile:1
# Arkime multi-stage build
# Base set to Debian Bookworm (provides libssl3)
ARG BASE_IMAGE=debian:bookworm-slim
FROM ${BASE_IMAGE} AS installer

ARG DEBIAN_FRONTEND=noninteractive
ARG ARKIME_VERSION=latest
ENV ARKIMEDIR=/opt/arkime

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      gnupg \
      apt-transport-https \
      libpcre3 \
      libyaml-0-2 \
      libssl3 \
      libmagic1 \
      curl \
      wget \
      logrotate \
      libwww-perl \
      libjson-perl; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p ${ARKIMEDIR}

# If you have a build step for Arkime sources, do it here.
# Example: download a release tarball and extract (adjust URL/version as needed)
# (This is optional — replace with your actual Arkime installer/build steps.)
RUN set -eux; \
    if [ "${ARKIME_VERSION}" != "latest" ]; then \
      echo "Downloading Arkime ${ARKIME_VERSION} (placeholder)"; \
      # Example placeholder; replace with real download if needed:
      # curl -fsSL -o /tmp/arkime.tar.gz "https://github.com/arkime/arkime/releases/download/${ARKIME_VERSION}/arkime-${ARKIME_VERSION}.tar.gz"; \
      # tar xzf /tmp/arkime.tar.gz -C ${ARKIMEDIR} --strip-components=1; \
    else \
      echo "Skipping Arkime download (set ARKIME_VERSION to real version to download)"; \
    fi

# Final runtime image
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ENV ARKIMEDIR=/opt/arkime
ENV PATH="${ARKIMEDIR}/bin:${PATH}"

# Install runtime dependencies (same family as installer)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      libpcre3 \
      libyaml-0-2 \
      libssl3 \
      libmagic1 \
      curl \
      logrotate \
      libwww-perl \
      libjson-perl; \
    rm -rf /var/lib/apt/lists/*

# Copy prepared files from installer stage
COPY --from=installer ${ARKIMEDIR} ${ARKIMEDIR}

# Create a non-root user to run Arkime processes (optional)
RUN set -eux; \
    groupadd -r arkime && useradd -r -g arkime -d ${ARKIMEDIR} -s /sbin/nologin arkime; \
    chown -R arkime:arkime ${ARKIMEDIR}

WORKDIR ${ARKIMEDIR}

# Expose default Arkime web port (adjust if needed)
EXPOSE 8005

# Replace with real start command for Arkime; this is a placeholder
USER arkime
CMD ["sh", "-c", "echo 'Replace this CMD with Arkime start command'; tail -f /dev/null"]
