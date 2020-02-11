ARG BUILD_FROM=hassioaddons/base:7.0.0
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
        gcc=9.2.0-r3 \
        libc-dev=0.7.2-r0 \
        libffi-dev=3.2.1-r6 \
        python3-dev=3.8.1-r0 \
    \
    && apk add --no-cache \
        python3=3.8.1-r0 \
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
    io.hass.name="appdaemon4" \
    io.hass.description="Python Apps and Dashboard using AppDaemon 4.x for Home Assistant" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Franck Nijhof <frenck@addons.community>" \
    org.label-schema.description="Python Apps and Dashboard using AppDaemon 4.x for Home Assistant" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="AppDaemon4" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://community.home-assistant.io/t/community-hass-io-add-on-appdaemon-4/163259?u=frenck" \
    org.label-schema.usage="https://github.com/hassio-addons/addon-appdaemon/tree/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/hassio-addons/addon-appdaemon" \
    org.label-schema.vendor="Community Hass.io Add-ons"
