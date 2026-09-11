ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base:9.4.0
# hadolint ignore=DL3006
FROM ghcr.io/astral-sh/uv:0.12.13 AS uv
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    PATH="/opt/appdaemon/bin:${PATH}" \
    UV_LINK_MODE=copy \
    UV_NO_CACHE=1 \
    UV_PYTHON_INSTALL_DIR=/usr/local/share/uv/python \
    VIRTUAL_ENV=/opt/appdaemon

COPY --from=uv /uv /usr/local/bin/uv

# Copy Python requirements file
COPY requirements.txt /tmp/

# We need to copy in the patches need during build
COPY rootfs/patches /patches

# Setup base
ARG BUILD_ARCH=amd64
ARG PYTHON_VERSION="3.13"
ARG YQ_VERSION="v4.53.6"
# hadolint ignore=DL3003,DL3008
RUN \
    apt-get update \
    \
    && apt-get install -y --no-install-recommends \
        patch \
    \
    && YQ_ARCH="${BUILD_ARCH}" \
    && if [ "${BUILD_ARCH}" = "aarch64" ]; then YQ_ARCH="arm64"; fi \
    && curl -fsSL -o /usr/bin/yq \
        "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${YQ_ARCH}" \
    && chmod a+x /usr/bin/yq \
    \
    && uv python install "${PYTHON_VERSION}" \
    && uv venv --seed --python "${PYTHON_VERSION}" "${VIRTUAL_ENV}" \
    && uv pip install --requirements /tmp/requirements.txt \
    \
    && cd "${VIRTUAL_ENV}/lib/python${PYTHON_VERSION}/site-packages/" \
    && patch -p1 < /patches/force_recompile.patch \
    \
    && find /usr/local/share/uv/python "${VIRTUAL_ENV}" \
        \( \
            \( -type d -a \( -name test -o -name tests -o -name idlelib \
                -o -name tkinter -o -name turtledemo -o -name ensurepip \
                -o -name __pycache__ \) \) \
            -o \( -type f -a \( -name '*.a' -o -name '*.pyc' -o -name '*.pyo' \) \) \
        \) \
        -exec rm -rf '{}' + \
    \
    && apt-get purge -y --auto-remove patch \
    && apt-get clean \
    && rm -fr \
        /tmp/* \
        /var/{cache,log}/* \
        /var/lib/apt/lists/*

# Copy root filesystem
COPY rootfs /

# Build arguments
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Franck Nijhof <opensource@frenck.dev>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Community Apps" \
    org.opencontainers.image.authors="Franck Nijhof <opensource@frenck.dev>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://frenck.dev/home-assistant-apps" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
