FROM ubuntu:14.04

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV PATH /root/.local/bin/:$PATH
ENV AULA_ROOT_PATH /liqd/aula
ENV AULA_SAMPLES /liqd/html-templates

# Download GHC and cabal
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:hvr/ghc && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 575159689BEFB442 && \
    echo 'deb http://download.fpcomplete.com/ubuntu trusty main' >/etc/apt/sources.list.d/fpco.list && \
    apt-get update && \
    apt-get install -y \
        zlib1g-dev libpq-dev libcurl4-gnutls-dev \
        sendmail tmux \
        stack git make vim g++ tidy curl

# Create development dirs
RUN mkdir -p /liqd/stack /liqd/html-templates

# Copy cabal file and install dependencies
COPY aula.yaml /liqd/aula/aula.yaml
COPY . /liqd/
WORKDIR /liqd/aula
RUN ln -s /liqd/stack .stack-work && \
    sed -i -e 's+^packages:+packages:\n- ../sensei+' stack.yaml && \
    stack setup && \
    stack install --fast --test --coverage --no-run-tests --only-dependencies aula

# Install tooling
RUN stack install --fast --test --coverage --no-run-tests sensei hpc-coveralls hlint
