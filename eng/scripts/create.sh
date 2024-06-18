#!/usr/bin/env bash

az stack sub create \
    --name 'default' \
    --template-file './src/main.bicep' \
    --parameters './src/parameters/main.bicepparam' \
    --deny-settings-mode 'none' \
    --delete-all \
    --yes
