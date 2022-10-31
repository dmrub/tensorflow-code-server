# shellcheck shell=bash
############### Configuration ###############

BASE_IMAGE_PREFIX=tensorflow/
BASE_IMAGE_NAME=tensorflow
BASE_IMAGE_TAG=2.2.0-gpu-jupyter
#BASE_IMAGE_TAG=2.4.3-gpu-jupyter
# shellcheck disable=SC2034
BASE_IMAGE=${BASE_IMAGE_PREFIX}${BASE_IMAGE_NAME}${BASE_IMAGE_TAG+:}${BASE_IMAGE_TAG}

#IMAGE_PREFIX=${IMAGE_PREFIX:-tensorflow-1.12.0-notebook-gpu}
IMAGE_TAG=${IMAGE_TAG:-${BASE_IMAGE_TAG}}
#IMAGE_NAME=${IMAGE_NAME:-${BASE_IMAGE_NAME}}
IMAGE_NAME=tensorflow-code-server
# shellcheck disable=SC2034
IMAGE=${IMAGE_PREFIX}${IMAGE_NAME}${IMAGE_TAG+:}${IMAGE_TAG}

############# End Configuration #############
