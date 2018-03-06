FROM saltyrtc/circleci-image-js-base:build

# Chromium
RUN apt-get update -qqy \
 && apt-get install -qqy --no-install-recommends \
    chromium-browser \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Add wrapper scripts
ADD xvfb-chromium /usr/local/bin/xvfb-chromium
RUN chmod +x /usr/local/bin/xvfb-chromium

# Switch user
USER ci

# Running this command as sudo just to avoid the message:
# To run a command as administrator (user "root"), use "sudo <command>". See "man sudo_root" for details.
# When logging into the container
RUN sudo echo ''

# Add certificates to Chrome
RUN xvfb-chromium & CHROMIUM_PID=$! && sleep 2 && kill $CHROMIUM_PID
RUN certutil -d sql:$HOME/.pki/nssdb -A -t "P,," -n saltyrtc-test-ca -i /saltyrtc/certs/saltyrtc.crt
