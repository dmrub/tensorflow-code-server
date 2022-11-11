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
    echo "$@"
}

usage() {
    echo "./docker-build.sh [-t|--tag image] [--no-cache]"
}

# shellcheck source=docker-config.sh
source "$THIS_DIR/docker-config.sh" || \
    fatal "Could not load configuration from $THIS_DIR/docker-config.sh"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--tag)
            IMAGE="$2"
            shift 2
            ;;
        --tag=*)
            IMAGE="${1#*=}"
            shift
            ;;
        --no-cache)
            NO_CACHE=--no-cache
            shift
            ;;
        --help)
            usage
            exit
            ;;
        --)
            shift
            break
            ;;
        -*)
            fatal "Unknown option $1"
            ;;
        *)
            break
            ;;
    esac
done

echo "Image Configuration:"
echo "IMAGE_NAME:        $IMAGE_NAME"
echo "IMAGE:             $IMAGE"
echo "NO_CACHE:          $NO_CACHE"

set -x
docker build \
    $NO_CACHE \
    --build-arg BASE_IMAGE="$BASE_IMAGE" \
    -t "${IMAGE}" \
    -f Dockerfile \
    "$THIS_DIR"
set +x
echo "Successfully built docker image $IMAGE"
