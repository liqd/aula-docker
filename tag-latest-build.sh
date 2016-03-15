#!/bin/sh -e

AULA_IMAGE=quay.io/liqd/aula

echo "Docker pull $AULA_IMAGE"
docker pull $AULA_IMAGE:latest

echo "Docker login to quay.io"
docker login quay.io

GIT_HASH=`docker run -it --rm $AULA_IMAGE:latest /bin/sh -c "cd /liqd && git rev-parse --short HEAD"`

# Remove trailing '\r' character from the end.
GIT_HASH=${GIT_HASH:0:7}

echo $GIT_HASH
echo "Tag build with $GIT_HASH and push."
docker tag $AULA_IMAGE:latest $AULA_IMAGE:$GIT_HASH
docker push $AULA_IMAGE:$GIT_HASH
