FROM ubuntu:xenial

# No interactive frontend during docker build
ENV DEBIAN_FRONTEND=noninteractive \
DEBCONF_NONINTERACTIVE_SEEN=true

# Base dependencies
RUN apt-get update -qqy \
 && apt-get install -qqy --no-install-recommends \
    locales \
    xvfb \
    wget \
    bzip2 \
    unzip \
    ca-certificates \
    sudo \
    libsodium18 \
    libsodium-dev \
    libnss3-tools \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Firefox
ARG FIREFOX_VERSION=50.0
RUN apt-get update -qqy \
 && apt-get -qqy --no-install-recommends install firefox \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
 && wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2 \
 && apt-get -y purge firefox \
 && rm -rf /opt/firefox \
 && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
 && rm /tmp/firefox.tar.bz2 \
 && mv /opt/firefox /opt/firefox-$FIREFOX_VERSION \
 && ln -fs /opt/firefox-$FIREFOX_VERSION/firefox /usr/bin/firefox

# Chromium
RUN apt-get update -qqy \
 && apt-get install -qqy --no-install-recommends \
    chromium-browser \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Add wrapper scripts
ADD xvfb-chromium /usr/local/bin/xvfb-chromium
ADD xvfb-firefox /usr/local/bin/xvfb-firefox
RUN chmod +x /usr/local/bin/xvfb-chromium && \
    chmod +x /usr/local/bin/xvfb-firefox

# Create non-root user
RUN useradd ci \
    --shell /bin/bash  \
    --create-home \
 && usermod -a -G sudo ci \
 && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
 && echo 'ci:secret' | chpasswd

# Switch user
USER ci

# Running this command as sudo just to avoid the message:
# To run a command as administrator (user "root"), use "sudo <command>". See "man sudo_root" for details.
# When logging into the container
RUN sudo echo ''
