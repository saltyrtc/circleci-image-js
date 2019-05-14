#!/bin/bash
set -Eeuo pipefail

# Generate CA
openssl genrsa -out /saltyrtc/certs/ca.key.pem 1024
openssl req \
    -config /saltyrtc/certs/openssl.cnf \
    -key /saltyrtc/certs/ca.key.pem \
    -new -x509 -days 365 -sha256 -extensions v3_ca \
    -subj "/CN=SaltyRTC CA" \
    -out /saltyrtc/certs/ca.cert.pem
openssl x509 -in /saltyrtc/certs/ca.cert.pem -text -noout

# Generate and sign localhost cert
openssl genrsa -out /saltyrtc/certs/localhost.key.pem 1024
openssl req \
    -config /saltyrtc/certs/openssl.cnf \
    -key /saltyrtc/certs/localhost.key.pem \
    -new -sha256 \
    -subj "/CN=localhost" \
    -out /saltyrtc/certs/localhost.csr.pem
openssl x509 \
    -extfile /saltyrtc/certs/openssl.cnf \
    -in /saltyrtc/certs/localhost.csr.pem \
    -req -days 365 -sha256 -extensions server_cert \
    -CA /saltyrtc/certs/ca.cert.pem \
    -CAkey /saltyrtc/certs/ca.key.pem \
    -CAcreateserial \
    -out /saltyrtc/certs/localhost.cert.pem
openssl x509 -in /saltyrtc/certs/localhost.cert.pem -text -noout
