#!/bin/bash

#
# This script is used to build the docker images for the different versions.
# It is used for local development.
#
# Usage: ./bin/build-develop.sh [dockerfile]
#
# Examples:
#   ./bin/build-develop.sh 8.2-fpm-minimal
#   ./bin/build-develop.sh 8.2-octane-minimal 8.2-fpm-minimal
#

if [ "$#" -eq 0 ]; then
  VERSION_MATRIX=('8.2-octane-minimal' '8.2-fpm-minimal')
else
  VERSION_MATRIX=("$@")
fi

for version in "${VERSION_MATRIX[@]}"
do
  echo "Checking requirements for $version"
  docker build -t "own3d/laravel-docker:$version-develop" "dockerfiles/$version"

  if [[ "$OSTYPE" == "msys" ]]; then
    winpty bash ./bin/check-platform-reqs.sh "$version-develop"
  else
    bash ./bin/check-platform-reqs.sh "$version-develop"
  fi
done