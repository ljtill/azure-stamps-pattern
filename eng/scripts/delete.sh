#!/usr/bin/env bash

az stack sub delete \
    --name 'default' \
    --delete-all \
    --yes
