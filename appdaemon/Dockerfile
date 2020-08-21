ARG BUILD_FROM=hassioaddons/base:8.0.1
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copy Python requirements file
COPY requirements.txt /tmp/

# We need to copy in the patches need during build
COPY rootfs/patches /patches

# Setup base
# hadolint ignore=DL3003
RUN \
    apk add --no-cache --virtual .build-dependencies \
        gcc=9.3.0-r2 \
        libc-dev=0.7.2-r3 \
        libffi-dev=3.2.1-r6 \
        python3-dev=3.8.5-r0 \
    \
    && apk add --no-cache \
        python3=3.8.5-r0 \
    \
    && pip3 install \
        --no-cache-dir \
        --prefer-binary \
        --find-links "https://wheels.hass.io/alpine-3.11/${BUILD_ARCH}/" \
        -r /tmp/requirements.txt \
    \
    && cd /usr/lib/python3.8/site-packages/ \
    && patch -p1 < /patches/force_recompile.patch \
    && patch -p1 < /patches/hassio.patch \
    \
    && find /usr/local \
        \( -type d -a -name test -o -name tests -o -name '__pycache__' \) \
        -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
        -exec rm -rf '{}' + \
    \
    && apk del --no-cache --purge .build-dependencies

# Copy root filesystem
COPY rootfs /

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="AppDaemon 4" \
    io.hass.description="Python Apps and Dashboard using AppDaemon 4.x for Home Assistant" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Franck Nijhof <frenck@addons.community>" \
    org.opencontainers.image.title="AppDaemon 4" \
    org.opencontainers.image.description="Python Apps and Dashboard using AppDaemon 4.x for Home Assistant" \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="Franck Nijhof <frenck@addons.community>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://addons.community" \
    org.opencontainers.image.source="https://github.com/hassio-addons/addon-appdaemon" \
    org.opencontainers.image.documentation="https://github.com/hassio-addons/addon-appdaemon/blob/master/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
