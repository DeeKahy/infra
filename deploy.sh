#!/bin/sh

export DOCKER_HOST=ssh://${DEPLOY_TARGET:-fklub.dk}

docker-compose -f compose.yml -f compose.production.yml up -d --build
