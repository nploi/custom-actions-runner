#!/bin/bash

# kind
curl -L https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64 -o /usr/local/bin/kind
chmod +x /usr/local/bin/kind

# docker-compose
curl -L "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

## gcloud cli
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
apt-get install -y apt-transport-https ca-certificates gnupg
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
apt-get update && apt-get install -y google-cloud-sdk

## kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

## helm
curl -LO https://get.helm.sh/helm-v3.10.1-linux-amd64.tar.gz
tar -zxvf helm-v3.10.1-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm

# jq (the default version is 1.5, which is too outdated)
curl -LO https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
install jq-linux64 /usr/bin/jq

# skaffold
curl -L https://github.com/GoogleContainerTools/skaffold/releases/download/v1.39.2/skaffold-linux-amd64 -o /usr/local/bin/skaffold
chmod +x /usr/local/bin/skaffold

# parallel
apt-get install -y parallel

## node
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt-get install -y nodejs
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list
apt-get update && apt-get install yarn

# Set the Chrome repo.
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | tee -a /etc/apt/sources.list.d/google.list

# Install Chrome.
apt-get update && apt-get -y install google-chrome-stable \
  && sed -i 's/"$@"/"$@" --no-sandbox --disable-dev-shm-usage/g' /opt/google/chrome/google-chrome

# Prepare a local registry for kind to use
docker pull kindest/node:v1.21.12@sha256:f316b33dd88f8196379f38feb80545ef3ed44d9197dca1bfd48bcb1583210207
docker pull registry:2
docker run -d --restart=always -p "127.0.0.1:5001:5000" --name "kind-registry" registry:2

images_to_cache=(
  asia.gcr.io/student-coach-e1e95/decrypt-secret:20220219
  asia.gcr.io/student-coach-e1e95/decrypt-secret:20220517
  asia.gcr.io/student-coach-e1e95/fake_firebase_token:1.1.0 # for emulators' firebase
  asia.gcr.io/student-coach-e1e95/customized-graphql-engine:v1.3.3.cli-migrations-v2
  asia.gcr.io/student-coach-e1e95/customized-graphql-engine:v2.8.1.cli-migrations-v3
  debian:11.3
  docker.io/istio/proxyv2:1.14.4 # for istio
  docker.io/istio/pilot:1.14.4   # for istio
  letsencrypt/pebble:v2.3.1      # for emulators' letsencrypt
  minio/mc:RELEASE.2020-12-18T10-53-53Z
  minio/minio:RELEASE.2020-12-23T02-24-12Z
  postgres:13.1              # for emulators' postgres
  mozilla/sops:v3.7.3-alpine # for sops decrypt
  nats:2.8.4-alpine3.15
  natsio/nats-box:0.8.1
  natsio/prometheus-nats-exporter:0.9.3
  natsio/nats-server-config-reloader:0.7.0
  asia.gcr.io/student-coach-e1e95/graphql-mesh:0.0.1
  asia.gcr.io/student-coach-e1e95/wait-for:0.0.1

  asia.gcr.io/student-coach-e1e95/customized_debezium_kafka:1.9.0 # for kafka
  asia.gcr.io/student-coach-e1e95/customized_debezium_connect:1.9.6
  asia.gcr.io/student-coach-e1e95/customized_cp_schema_registry:7.1.2
  asia.gcr.io/student-coach-e1e95/kafkatools:0.0.2
  provectuslabs/kafka-ui:latest

  asia.gcr.io/student-coach-e1e95/customized-graphql-engine-v2:v1.3.3.cli-migrations-v2
  # import-map-deployer
  asia.gcr.io/student-coach-e1e95/import-map-deployer:0.0.1
  google/cloud-sdk:323.0.0-alpine

  # elastic
  amazon/opendistro-for-elasticsearch-kibana:1.13.1
  asia.gcr.io/student-coach-e1e95/customized_elastic:1.13.1
  quay.io/prometheuscommunity/elasticsearch-exporter:v1.2.1

  # unleash
  unleashorg/unleash-server:4.8.2
  unleashorg/unleash-proxy:0.7.1
  node:14-alpine

  # cert-manager
  quay.io/jetstack/cert-manager-acmesolver:v1.7.1
  quay.io/jetstack/cert-manager-cainjector:v1.7.1
  quay.io/jetstack/cert-manager-controller:v1.7.1
  quay.io/jetstack/cert-manager-ctl:v1.7.1
  quay.io/jetstack/cert-manager-webhook:v1.7.1
)
for image in "${images_to_cache[@]}"; do
  docker pull "${image}"
  docker tag "${image}" "localhost:5001/${image}"
  docker push "localhost:5001/${image}"
  docker rmi "${image}"
  docker rmi "localhost:5001/${image}"
done
