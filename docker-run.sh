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

mkdir -p "${THIS_DIR}/tf"

set -x
docker run --rm -it  --gpus=all --net=host -e DEFAULT_WORKSPACE=/tf -v "${THIS_DIR}/tf:/tf" -p 8888:8888 "$IMAGE"
