FROM debian:bullseye as installer

# Declare args
ARG ARKIME_VERSION=5.0.0
ARG UBUNTU_VERSION=20.04
ARG ARKIME_DEB_PACKAGE="arkime_${ARKIME_VERSION}-1_amd64.deb"
ARG ARKIMEDIR="/opt/arkime"

ENV ARKIME_VERSION=${ARKIME_VERSION}
ENV UBUNTU_VERSION=${UBUNTU_VERSION}
ENV ARKIME_DEB_PACKAGE=${ARKIME_DEB_PACKAGE}
ENV ARKIMEDIR=${ARKIMEDIR}
ENV DEBIAN_FRONTEND=noninteractive

# Install tools needed to fetch/install the Arkime deb
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      wget \
      logrotate && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp /suricata-logs

WORKDIR /tmp
RUN wget -q "https://s3.amazonaws.com/files.molo.ch/builds/ubuntu-${UBUNTU_VERSION}/${ARKIME_DEB_PACKAGE}"
# install the downloaded deb (let apt resolve deps)
RUN apt-get update && apt-get install -y --no-install-recommends ./${ARKIME_DEB_PACKAGE} && rm -rf /var/lib/apt/lists/*

RUN wget -q -O /opt/arkime/etc/oui.txt "https://www.wireshark.org/download/automated/data/manuf"
RUN ${ARKIMEDIR}/bin/arkime_update_geo.sh


# add config

FROM debian:bullseye as runner

# Runtime environment / defaults
ENV ES_HOST="elasticsearch"
ENV ES_PORT=9200
ENV ARKIME_ADMIN_USERNAME="selks-user"
ENV ARKIME_ADMIN_PASSWORD="selks-user"
ENV ARKIME_HOSTNAME="arkime"
ENV ARKIMEDIR="/opt/arkime"
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies in one layer and clean apt lists.
# NOTE: bullseye provides OpenSSL 1.1 (libssl1.1), not libssl3 — replace libssl3 with libssl1.1.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      libpcre3 \
      libyaml-0-2 \
      libssl1.1 \
      libmagic1 \
      curl \
      libwww-perl \
      libjson-perl && \
    rm -rf /var/lib/apt/lists/*

COPY --from=installer ${ARKIMEDIR} ${ARKIMEDIR}

COPY start-arkimeviewer.sh /start-arkimeviewer.sh
COPY arkimepcapread-selks-config.ini /opt/arkime/etc/config.ini

RUN chmod 755 /start-arkimeviewer.sh && \
    mkdir -p /readpcap

EXPOSE 8005
WORKDIR ${ARKIMEDIR}

ENTRYPOINT [ "bash", "-c" ]
CMD ["/start-arkimeviewer.sh"]
