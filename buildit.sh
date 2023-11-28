#!/bin/bash -e

ORGNAME=andyg42
if [ "$VERSION" == "" ]; then
  VERSION=DEV
fi

echo --------------------------
echo Building gem...
echo --------------------------
# gem build es-migration-tools.gemspec
rake test
rake build

echo --------------------------
echo Building docker image...
echo --------------------------
docker build . -t $ORGNAME/esmigration:$VERSION

echo --------------------------
echo Uploading docker image...
echo --------------------------
docker push $ORGNAME/esmigration:$VERSION
