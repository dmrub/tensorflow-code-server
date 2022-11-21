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

usage() {
    echo "./docker-run.sh [--net=*] [--as-root] [--]"
}


# shellcheck source=docker-config.sh
source "$THIS_DIR/docker-config.sh" || \
    fatal "Could not load configuration from $THIS_DIR/docker-config.sh"


# USER_DIR=/tf
USER_DIR=/home/jovyan

ARGS=()


AS_USER="$(id -u):$(id -g)"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --net=*)
            ARGS+=("$1")
            shift
            ;;
        --help)
            usage
            exit
            ;;
        --as-root)
            AS_USER="root:root"
            shift
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

mkdir -p "${THIS_DIR}/user_data"

if [[ -n "$PASSWORD" ]]; then
    ARGS+=(-e "PASSWORD=$PASSWORD")
fi

if [[ -n "$HASHED_PASSWORD" ]]; then
    ARGS+=(-e "HASHED_PASSWORD=$HASHED_PASSWORD")
fi

set -x
docker run --rm -it  \
    --gpus=all \
    -u "$AS_USER" \
    "${ARGS[@]}" \
    -e "DEFAULT_WORKSPACE=${USER_DIR}" \
    -v "${THIS_DIR}/user_data:${USER_DIR}" \
    -p 8888:8888 "$IMAGE"
