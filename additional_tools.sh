#!/bin/bash

apt update

# kind
curl -L https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64 -o /usr/local/bin/kind
chmod +x /usr/local/bin/kind

# docker-compose
curl -L "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
apt install docker-compose-plugin

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

# Github CLI
export GH_VERSION=2.20.2
curl -fLO https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz
tar -zxvf gh_${GH_VERSION}_linux_amd64.tar.gz
mv gh_${GH_VERSION}_linux_amd64/bin/gh /usr/local/bin/gh
rm -rf gh_${GH_VERSION}_linux_amd64.tar.gz gh_${GH_VERSION}_linux_amd64

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
