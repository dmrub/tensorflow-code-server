ARG BASE_IMAGE=tensorflow/tensorflow:2.2.0-gpu-jupyter

FROM $BASE_IMAGE

LABEL org.opencontainers.image.authors="Dmitri Rubinstein"
LABEL org.opencontainers.image.source="https://github.com/dmrub/tensorflow-codes-erver"

ARG S6_ARCH="x86_64"
ARG S6_OVERLAY_VERSION=3.1.2.1

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-${S6_ARCH}.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz

ENTRYPOINT ["/init"]

# Workaround
# https://github.com/NVIDIA/nvidia-docker/issues/1632#issuecomment-1135513277
RUN set -ex; \
    apt-key del 7fa2af80; \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub; \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64/7fa2af80.pub;

# From https://github.com/kubeflow/kubeflow/blob/master/components/example-notebook-servers/base/Dockerfile
# install - usefull linux packages
RUN set -ex; \
    \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update -yq; \
    apt-get install -yq --no-install-recommends \
        htop \
        rsync \
        openssh-client \
        apt-transport-https \
        bash \
        bzip2 \
        ca-certificates \
        curl \
        git \
        gnupg \
        gnupg2 \
        locales \
        nano \
        tzdata \
        unzip \
        vim \
        wget \
        zip; \
        \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*;
# From https://github.com/kubeflow/kubeflow/blob/master/components/example-notebook-servers/codeserver/Dockerfile

RUN if command -v conda >/dev/null 2>&1; then \
        if ! conda list ipywidgets | grep -qF ipywidgets; then \
            conda install ipywidgets; \
        fi; \
    elif ! python3 -m pip show ipywidgets; then \
        python3 -m pip install ipywidgets; \
    fi; \
    \
    if ! python3 -c "import ipywidgets"; then \
        echo >&2 "Could not install ipywidgets module"; \
        exit 1; \
    fi;

# RUN set -ex; sh -c "type /usr/bin/python3; exit 3";

# set locale configs
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
 && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# args - software versions
 # renovate: datasource=github-tags depName=cdr/code-server versioning=semver
#ARG CODESERVER_VERSION=v4.8.0
ARG CODESERVER_VERSION=v4.7.1

# install - code-server
RUN set -ex; \
    \
    apt-get update -yq; \
    curl -sL "https://github.com/cdr/code-server/releases/download/${CODESERVER_VERSION}/code-server_${CODESERVER_VERSION/v/}_amd64.deb" -o /tmp/code-server.deb; \
    dpkg -i /tmp/code-server.deb; \
    rm -f /tmp/code-server.deb; \
    \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*;


#ARG CODESERVER_PYTHON_VERSION=2022.17.13001027
ARG CODESERVER_PYTHON_VERSION=2022.8.1
# install - codeserver extensions
RUN set -ex; \
    \
    URL="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/python/${CODESERVER_PYTHON_VERSION}/vspackage"; \
    MAX=10; \
    I=0; \
    while [ $I -lt $MAX ] && ! curl --compressed -# -f -L -o /tmp/ms-python-release.vsix "$URL"; do \
        sleep 1; \
        I=$((I+1)); \
    done; \
    code-server --install-extension /tmp/ms-python-release.vsix; \
    code-server --list-extensions --show-versions;

# s6 - copy scripts
COPY --chown=root:root s6/ /etc
RUN chmod +x /etc/services.d/code-server/run

RUN pip3 --no-cache-dir install jupyterlab
