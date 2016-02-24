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
    apt-get update && \
    apt-get install -y \
        cabal-install-1.22 \
        ghc-7.10.3 \
        cpphs \
        happy-1.19.3 \
        alex-3.1.4 \
        git \
        zlib1g-dev \
        g++ \
        libpq-dev \
        tidy \
        libcurl4-gnutls-dev \
        make
ENV PATH /opt/ghc/7.10.3/bin:/opt/cabal/1.22/bin:/opt/alex/3.1.4/bin:/opt/happy/1.19.3/bin:$PATH

# Create development dirs
RUN mkdir /liqd/ && \
    mkdir /root/aula && \
    mkdir /root/thentos && \
    mkdir /root/html-templates

# Copy cabal file and install dependencies
ENV AULA_SANDBOX=/liqd/thentos/.cabal-sandbox
COPY . /liqd/
RUN cabal update && \
    cd /liqd/thentos/ && \
    ./misc/thentos-install.hs -p && \
    cd /liqd/aula/ && \
    cabal sandbox init --sandbox=$AULA_SANDBOX && \
    cabal install --enable-tests --only-dependencies && \
    cd /liqd/sensei/ && \
    cabal sandbox init --sandbox=$AULA_SANDBOX && \
    cabal install && \
    cd / && \
    cabal install hpc-coveralls hlint hpack-0.8.0 --global --reorder-goals

# Directory for aula, thentos sources
VOLUME "/root/aula"
VOLUME "/root/thentos"

# Directory for the html templates
VOLUME "/root/html-templates"

# Offer aula-server listener port to host
EXPOSE 8080
