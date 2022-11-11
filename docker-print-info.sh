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


echo "BASE_IMAGE:      $BASE_IMAGE"
echo "BASE_IMAGE_NAME: $BASE_IMAGE_NAME"
echo "BASE_IMAGE_TAG:  $BASE_IMAGE_TAG"
echo "IMAGE_NAME:      $IMAGE_NAME"
echo "IMAGE_TAG:       $IMAGE_TAG"
echo "IMAGE:           $IMAGE"
