#!/usr/bin/env bash

set -eo pipefail

THIS_DIR=$( cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P )

error() {
    echo >&2 "* Error: $*"
}

fatal() {
    error "$@"
    exit 1
}

message() {
    echo "* $*"
}

# shellcheck source=docker-config.sh
source "$THIS_DIR/docker-config.sh" || \
    fatal "Could not load configuration from $THIS_DIR/docker-config.sh"

mkdir -p "${THIS_DIR}/user_data"

# USER_DIR=/tf
USER_DIR=/home/jovyan

ARGS=()

if [[ -n "$PASSWORD" ]]; then
    ARGS+=(-e "PASSWORD=$PASSWORD")
fi

if [[ -n "$HASHED_PASSWORD" ]]; then
    ARGS+=(-e "HASHED_PASSWORD=$HASHED_PASSWORD")
fi

set -x
docker run --rm -it  \
    --gpus=all --net=host \
    -u "$(id -u):$(id -g)" \
    "${ARGS[@]}" \
    -e "DEFAULT_WORKSPACE=${USER_DIR}" \
    -v "${THIS_DIR}/user_data:${USER_DIR}" \
    -p 8888:8888 "$IMAGE"
