FROM ubuntu:14.04

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV PATH /root/.local/bin/:$PATH
ENV THENTOS_ROOT_PATH /liqd/thentos/thentos-core

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

# Create development dirs
RUN mkdir -p /liqd/stack /liqd/html-templates && \
    echo 'export AULA_SAMPLES=/liqd/html-templates' >> /root/.bashrc

# Copy cabal file and install dependencies
COPY . /liqd/
WORKDIR /liqd/aula
RUN ln -s /liqd/stack .stack-work && \
    sed -i -e 's+^packages:+packages:\n- ../sensei+' stack.yaml && \
    stack setup && \
    stack install --fast --test --coverage --no-run-tests --only-dependencies thentos-core aula

# Install tooling
RUN stack install --fast --test --coverage --no-run-tests sensei hpc-coveralls hlint
