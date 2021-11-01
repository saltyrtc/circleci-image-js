FROM ubuntu:bionic

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
    git \
    locales \
    libsodium23 \
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

# NodeJS / npm
RUN wget -qO- https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Create non-root user
RUN useradd ci \
    --shell /bin/bash  \
    --create-home \
 && usermod -a -G sudo ci \
 && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
 && echo 'ci:secret' | chpasswd

# Create test certificates
ADD generate-cert.sh /saltyrtc/certs/generate-cert.sh
ADD openssl.cnf /saltyrtc/certs/openssl.cnf
RUN bash /saltyrtc/certs/generate-cert.sh && \
    chmod a+r /saltyrtc/certs/*

# Update directory permissions
RUN chmod a+w /saltyrtc

# Install SaltyRTC server
RUN pip3 install saltyrtc.server[logging]

# Export SaltyRTC test permanent key
ENV SALTYRTC_SERVER_PERMANENT_KEY=0919b266ce1855419e4066fc076b39855e728768e3afa773105edd2e37037c20

# Add wrapper scripts
ADD saltyrtc-server-launcher /usr/local/bin/saltyrtc-server-launcher
RUN chmod +x /usr/local/bin/saltyrtc-server-launcher
