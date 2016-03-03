FROM ubuntu:14.04

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# Download GHC and cabal
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:hvr/ghc && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 575159689BEFB442 && \
    echo 'deb http://download.fpcomplete.com/ubuntu trusty main' >/etc/apt/sources.list.d/fpco.list && \
    apt-get update && \
    apt-get install -y \
        stack \
        git \
        zlib1g-dev \
        g++ \
        libpq-dev \
        tidy \
        libcurl4-gnutls-dev \
        make vim tmux
ENV THENTOS_ROOT_PATH /liqd/thentos/thentos-core

# Create development dirs
RUN mkdir /liqd/ && \
    mkdir /root/aula && \
    mkdir /root/thentos && \
    mkdir /root/html-templates && \
    echo 'export AULA_SAMPLES=/root/html-templates >> /root/.bashrc'

# Copy cabal file and install dependencies
COPY . /liqd/
RUN cabal update && \
    cd /liqd/aula/ && \
    sed -i -e 's+packages:+packages:\n- ../sensei+' stack.yaml &&
    stack setup && \
    stack install --fast --test --no-run-tests --only-dependencies && \
    stack install --fast --test --no-run-tests thentos-core sensei hpc-coveralls hlint hpack-0.8.0

# Directory for aula, thentos sources
VOLUME "/root/aula"
VOLUME "/root/thentos"

# Directory for the html templates
VOLUME "/root/html-templates"

# Offer aula-server listener port to host
EXPOSE 8080
