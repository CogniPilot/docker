#!/bin/bash
set -e

if [[ -z "$SSH_AUTH_SOCK" ]]; then
    echo "ERROR: please start your ssh-agent" >&2
    exit 1
fi
export HOST_UID=$(id -u)
export HOST_GID=$(id -g)
docker compose run dream $1
