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
    locales \
    libsodium18 \
    libsodium-dev \
    libnss3-tools \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Fix locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

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

# NodeJS / npm
RUN wget -qO- https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Add wrapper scripts
ADD xvfb-chromium /usr/local/bin/xvfb-chromium
ADD xvfb-firefox /usr/local/bin/xvfb-firefox
ADD saltyrtc-server-launcher /usr/local/bin/saltyrtc-server-launcher
RUN chmod +x /usr/local/bin/xvfb-chromium && \
    chmod +x /usr/local/bin/xvfb-firefox && \
    chmod +x /usr/local/bin/saltyrtc-server-launcher

# Create non-root user
RUN useradd ci \
    --shell /bin/bash  \
    --create-home \
 && usermod -a -G sudo ci \
 && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
 && echo 'ci:secret' | chpasswd

# Create test certificates
ADD saltyrtc.ext /saltyrtc/certs/saltyrtc.ext
RUN openssl req -new -newkey rsa:1024 -nodes -sha256 -out /saltyrtc/certs/saltyrtc.csr -keyout /saltyrtc/certs/saltyrtc.key -subj '/C=CH/O=SaltyRTC/CN=localhost/' && \
    openssl x509 -req -days 1825 -in /saltyrtc/certs/saltyrtc.csr -signkey /saltyrtc/certs/saltyrtc.key -sha256 -extfile /saltyrtc/certs/saltyrtc.ext -out /saltyrtc/certs/saltyrtc.crt && \
    chmod a+r /saltyrtc/certs/*

# Update directory permissions
RUN chmod a+w /saltyrtc

# Install SaltyRTC server
RUN pip3 install saltyrtc.server[logging]

# Switch user
USER ci

# Running this command as sudo just to avoid the message:
# To run a command as administrator (user "root"), use "sudo <command>". See "man sudo_root" for details.
# When logging into the container
RUN sudo echo ''

# Add certificates to Firefox and Chrome
RUN mkdir -p ~/.mozilla/firefox/saltyrtc && \
    certutil -d ~/.mozilla/firefox/saltyrtc -A -n saltyrtc-test-ca -t Ccw,, -i /saltyrtc/certs/saltyrtc.crt

# Increase websocket connection limit
RUN echo 'user_pref("network.websocket.max-connections", 400);' >> ~/.mozilla/firefox/saltyrtc/prefs.js

# Export SaltyRTC test permanent key
ENV SALTYRTC_SERVER_PERMANENT_KEY=0919b266ce1855419e4066fc076b39855e728768e3afa773105edd2e37037c20
