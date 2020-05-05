#!/bin/bash

openssl req -x509 -newkey rsa:4096 -keyout root-ca-key.pem -out root-ca.pem -days 730 -nodes -config ca-ssl.conf

# Display subject of certificate
openssl x509 -in root-ca.pem -subject -noout

# Generate Node certificates
openssl req -newkey rsa:4096 -keyout key.pem -out node-cert.csr -days 730 -nodes -config node-ssl.conf
openssl x509 -req -in node-cert.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -out node-cert.pem -extensions req_ext -extfile node-ssl.conf -days 730
openssl x509 -noout -issuer -in node-cert.pem

# Generate Admin certificates
openssl req -newkey rsa:4096 -keyout admin-key.pem -out admin-cert.csr -days 730 -nodes -config admin-ssl.conf
openssl x509 -req -in admin-cert.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -out admin-cert.pem -extensions req_ext -days 730 -extfile admin-ssl.conf 
openssl x509 -noout -issuer -in admin-cert.pem


