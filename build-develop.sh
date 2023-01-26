#!/bin/bash

###
# Create image for
#
#

# Usage: build-develop.sh [dockerfile]

if [ "$#" -eq 0 ]; then
  VERSION_MATRIX=('8.0-octane' '8.0-fpm' '7.4-fpm')
else
  VERSION_MATRIX=("$@")
fi

for version in "${VERSION_MATRIX[@]}"
do
  echo "Checking requirements for $version"
  docker build -t "own3d/laravel-docker:$version-develop" "dockerfiles/$version"
  bash check-platform-reqs.sh "$version-develop"
done