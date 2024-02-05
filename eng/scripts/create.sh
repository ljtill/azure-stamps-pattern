#!/usr/bin/env bash

az stack sub create \
    --name 'default' \
    --template-file './src/main.bicep' \
    --parameters './src/main.bicepparam' \
    --deny-settings-mode 'none' \
    --delete-all \
    --yes
