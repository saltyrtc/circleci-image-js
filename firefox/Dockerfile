FROM saltyrtc/circleci-image-js-base:build

# Firefox
ARG BROWSER_VERSION=50.1.0
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
RUN mkdir -p ~/.mozilla/firefox/saltyrtc && \
    certutil -d ~/.mozilla/firefox/saltyrtc -A -n saltyrtc-test-ca -t Ccw,, -i /saltyrtc/certs/saltyrtc.crt

# Increase websocket connection limit
RUN echo 'user_pref("network.websocket.max-connections", 400);' >> ~/.mozilla/firefox/saltyrtc/prefs.js
