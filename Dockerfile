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
        libpq-dev
ENV PATH /opt/ghc/7.10.3/bin:/opt/cabal/1.22/bin:/opt/alex/3.1.4/bin:/opt/happy/1.19.3/bin:$PATH

# Create development dirs
RUN mkdir /liqd/ && \
    mkdir /root/aula

# Copy cabal file and install dependencies
COPY . /liqd/
RUN cabal update && \
    cd /liqd/thentos/ && \
    ./misc/thentos-install.hs -p && \
    cd /liqd/aula/ && \
    cabal sandbox init --sandbox=/liqd/thentos/.cabal-sandbox && \
    cabal install --enable-tests --only-dependencies

# Directory for aula source
VOLUME "/root/aula"
