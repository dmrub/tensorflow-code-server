ARG BASE_IMAGE=tensorflow/tensorflow:2.2.0-gpu-jupyter

FROM $BASE_IMAGE

LABEL org.opencontainers.image.authors="Dmitri Rubinstein"
LABEL org.opencontainers.image.source="https://github.com/dmrub/tensorflow-codes-erver"

ARG S6_ARCH="x86_64"
ARG S6_OVERLAY_VERSION=3.1.2.1
ARG KUBECTL_ARCH="amd64"
ARG KUBECTL_VERSION=v1.21.0
ARG KUBECTL_INSTALL=1

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-${S6_ARCH}.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz

ENTRYPOINT ["/init"]

# Compatibility with kubeflow
# https://github.com/kubeflow/kubeflow/blob/master/components/example-notebook-servers/base/Dockerfile
ARG NB_USER
ARG NB_GROUP
ARG NB_UID
ARG NB_PREFIX
ARG HOME

ENV NB_USER ${NB_USER:-jovyan}
ENV NB_GROUP ${NB_GROUP:-users}
ENV NB_UID ${NB_UID:-1000}
ENV NB_PREFIX ${NB_PREFIX:-/}
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME 0
ENV HOME /home/$NB_USER
ENV SHELL /bin/bash

# set shell to bash
SHELL ["/bin/bash", "-c"]

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
        sudo \
        htop \
        rsync \
        openssh-client \
        apt-transport-https \
        bash \
        bash-completion \
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
    if command -v python3 >/dev/null 2>&1; then \
        if ! python3 -Im ensurepip --version; then \
            apt-get install -yq --no-install-recommends python3-venv; \
        fi; \
    fi; \
    \
    # create user and set required ownership
    useradd -M -s "$SHELL" -N -u ${NB_UID} ${NB_USER}; \
    if [[ -n "$HOME" && ! -d "$HOME" ]]; then \
        mkdir -p "${HOME}"; \
        chown "$NB_USER:$NB_GROUP" -R "$HOME"; \
    fi; \
    if [[ ! -f /etc/sudoers ]] || ! grep -q "^${NB_USER}[[:space:]]" /etc/sudoers; then \
        if [[ ! -f /etc/sudoers ]]; then \
            touch /etc/sudoers; \
        fi; \
        chmod 0660 /etc/sudoers; \
        echo "${NB_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers; \
        chmod 0440 /etc/sudoers; \
    fi; \
    \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*;

# install - kubectl
RUN set -ex; \
    if [ "x${KUBECTL_INSTALL}" != "x" ]; then \
      curl -sL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl" -o /usr/local/bin/kubectl; \
      curl -sL "https://dl.k8s.io/${KUBECTL_VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl.sha256" -o /tmp/kubectl.sha256; \
      echo "$(cat /tmp/kubectl.sha256) /usr/local/bin/kubectl" | sha256sum --check; \
      rm /tmp/kubectl.sha256; \
      chmod +x /usr/local/bin/kubectl; \
    fi;

RUN if command -v conda >/dev/null 2>&1; then \
        if ! conda list ipywidgets | grep -qF ipywidgets; then \
            conda install ipywidgets -y; \
        fi; \
    elif ! python3 -m pip show ipywidgets; then \
        python3 -m pip install ipywidgets; \
    fi; \
    \
    if ! python3 -c "import ipywidgets"; then \
        echo >&2 "Could not install ipywidgets module"; \
        exit 1; \
    fi;

# set locale configs
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
 && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# From https://github.com/kubeflow/kubeflow/blob/master/components/example-notebook-servers/codeserver/Dockerfile
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

# s6 - 01-copy-tmp-home
RUN set -ex; \
    mkdir -p /tmp_home; \
    cp -r "${HOME}" /tmp_home; \
    chown -R "${NB_USER}:${NB_GROUP}" /tmp_home;

RUN pip3 --no-cache-dir install jupyterlab

USER $NB_USER
