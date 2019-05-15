FROM saltyrtc/circleci-image-js-base:build

# Firefox
ARG BROWSER_VERSION
RUN apt-get update -qqy \
 && apt-get -qqy --no-install-recommends install firefox libasound2 \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
 && wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/$BROWSER_VERSION/linux-x86_64/en-US/firefox-$BROWSER_VERSION.tar.bz2 \
 && apt-get -y purge firefox \
 && rm -rf /opt/firefox \
 && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
 && rm /tmp/firefox.tar.bz2 \
 && mv /opt/firefox /opt/firefox-$BROWSER_VERSION \
 && ln -fs /opt/firefox-$BROWSER_VERSION/firefox /usr/bin/firefox

# Add wrapper scripts
ADD xvfb-firefox /usr/local/bin/xvfb-firefox
RUN chmod +x /usr/local/bin/xvfb-firefox

# Switch user
USER ci

# Running this command as sudo just to avoid the message:
# To run a command as administrator (user "root"), use "sudo <command>". See "man sudo_root" for details.
# When logging into the container
RUN sudo echo ''

# Add certificates to Firefox
RUN mkdir -p /home/ci/.mozilla/firefox/saltyrtc && \
    certutil -d sql:/home/ci/.mozilla/firefox/saltyrtc -A -n saltyrtc-test-ca -t C,, -i /saltyrtc/certs/ca.cert.pem

# Increase websocket connection limit
RUN echo 'user_pref("network.websocket.max-connections", 400);' >> /home/ci/.mozilla/firefox/saltyrtc/prefs.js
