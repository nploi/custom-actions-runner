#!/bin/bash

## install cypress
cd /home/runner
yarn add cypress@6.7.0
sed -i -e 's|api_url:.*$|api_url: "https://cypress-director.staging.manabie.io:31600/"|g' ~/.cache/Cypress/*/Cypress/resources/app/packages/server/config/app.yml
# sudo DEBIAN_FRONTEND=noninteractive apt-get install keyboard-configuration
# sudo apt-get update && sudo apt-get install -y libgtk2.0-0 libgtk-3-0 libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb zip

sudo chown -R runner ~/.cache/Cypress/