#!/bin/bash
openssl req \
    -newkey rsa:1024 \
    -x509 \
    -nodes \
    -keyout /saltyrtc/certs/saltyrtc.key \
    -new \
    -out /saltyrtc/certs/saltyrtc.crt \
    -subj /CN=localhost \
    -reqexts SAN \
    -extensions SAN \
    -config <(cat /etc/ssl/openssl.cnf \
        <(printf '[SAN]\nsubjectAltName=DNS:localhost')) \
    -sha256 \
    -days 1825
