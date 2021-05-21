#!/bin/bash

VERSION_MATRIX=('develop' '8.0-octane-develop' '8.0-fpm-develop' '7.4-fpm-develop')
EXTENSION_MATRIX=(
  'bcmath' 'curl' 'date' 'imagick' 'exif' 'fileinfo' 'hash' 'PDO' 'sockets'
  'json' 'mbstring' 'pdo_mysql' 'pdo_sqlite' 'sqlite3' 'zip' 'pcntl' 'redis'
  'swoole' 'posix' 'gd' 'mongodb'
)

for version in "${VERSION_MATRIX[@]}"
do
  if  [ "$version" != "develop" ] ; then
    docker pull "own3d/laravel-docker:$version"
  fi

  for extension in "${EXTENSION_MATRIX[@]}"
  do
    command="$command if(!extension_loaded('$extension')) { echo 'ERROR: Extension $extension on $version is missing.' . PHP_EOL;}"
  done
  docker run -it --rm "own3d/laravel-docker:$version" php -r "$command"
done