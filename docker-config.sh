# shellcheck shell=bash
############### Configuration ###############

# shellcheck disable=SC2034
# BASE_IMAGE=tensorflow/tensorflow:2.8.4-gpu-jupyter
BASE_IMAGE=nvcr.io/nvidia/pytorch:21.12-py3

# IMAGE_PREFIX=${IMAGE_PREFIX:-}

BASE_IMAGE_TAG=${BASE_IMAGE#*:};
BASE_IMAGE_NAME=${BASE_IMAGE%%:*};
case "$BASE_IMAGE_NAME" in
  tensorflow/tensorflow) IMAGE_NAME=tensorflow-code-server;;
  nvcr.io/nvidia/pytorch) IMAGE_NAME=pytorch-code-server;;
  ghcr.io/dmrub/fastai) IMAGE_NAME=fastai-code-server;;
  *) echo >&2 "Error: unknown base image: $BASE_IMAGE_NAME"; exit 1;;
esac;

IMAGE_TAG=${IMAGE_TAG:-${BASE_IMAGE_TAG}}

# shellcheck disable=SC2034
IMAGE=${IMAGE_PREFIX}${IMAGE_NAME}${IMAGE_TAG+:}${IMAGE_TAG}

#PASSWORD=password
#HASHED_PASSWORD='$argon2id$v=19$m=65536,t=3,p=4$uYV2rm2QmqutZ0lJ5wtvgg$x23V0cNzQjxe6CnNpU1anWmJXwGS2TMz80ePrgwHjRo'
############# End Configuration #############
