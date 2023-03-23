#!/usr/bin/env bash

# run docker using compose in detached mode
docker compose -f ~/compose.yml up -d --build --force-recreate
