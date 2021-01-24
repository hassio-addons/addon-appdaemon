#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: AppDaemon
# Configures AppDaemon
# ==============================================================================
declare arch

# Creates initial AppDaemon configuration in case it is non-existing
if ! bashio::fs.directory_exists '/config/appdaemon'; then
    cp -R /root/appdaemon /config/appdaemon \
        || bashio::exit.nok 'Failed to create initial AppDaemon configuration'
fi

# Install user configured/requested packages
if bashio::config.has_value 'system_packages'; then
    apk update \
        || bashio::exit.nok 'Failed updating Alpine packages repository indexes'

    for package in $(bashio::config 'system_packages'); do
        apk add "$package" \
            || bashio::exit.nok "Failed installing package ${package}"
    done
fi

# Install user configured/requested Python packages
if bashio::config.has_value 'python_packages'; then
    arch=$(bashio::info.arch)
    for package in $(bashio::config 'python_packages'); do
        pip3 install \
            --prefer-binary \
            --find-links "https://wheels.home-assistant.io/alpine-3.13/${arch}/" \
            "$package" \
                || bashio::exit.nok "Failed installing package ${package}"
    done
fi

# Executes user configured/requested commands on startup
if bashio::config.has_value 'init_commands'; then
    while read -r cmd; do
        eval "${cmd}" \
            || bashio::exit.nok "Failed executing init command: ${cmd}"
    done <<< "$(bashio::config 'init_commands')"
fi
