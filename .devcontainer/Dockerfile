ARG VARIANT=ubuntu-21.04
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

ARG NONINTERACTIVE=1
RUN sudo apt-get update && \
    sudo apt-get install -y \
      build-essential \
      curl \
      file \
      gcc \
      git \
      procps ;
