#!/bin/bash
ES_NODES="node1 node2 kibana admin keycloak"
openssl genrsa -out ca.key 2048 > /dev/null 2>&1
openssl req -x509 -new -nodes -key ca.key -days 10000 -out ca.pem -subj "/CN=ca" > /dev/null 2>&1

for node in ${ES_NODES}; do
    openssl genrsa -out ${node}.key 2048
    openssl req -new -key ${node}.key -out ${node}.csr -subj "/CN=${node}"
    openssl x509 -req -in ${node}.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out ${node}.pem -days 7200 -extensions v3_req -extfile ssl.conf
done