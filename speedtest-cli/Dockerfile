ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/amd64:stable
# hadolint ignore=DL3006
FROM ${BUILD_FROM}
RUN apt-get update && apt-get dist-upgrade -y && apt-get install curl -y && curl -s https://install.speedtest.net/app/cli/install.deb.sh | bash && apt-get install speedtest jq cron -y && apt-get clean all && rm -rf /var/lib/apt/lists/*
#Accept license
RUN /usr/bin/speedtest --accept-license --accept-gdpr
COPY rootfs /
RUN chmod +x /speedtestcli.sh

