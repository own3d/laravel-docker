#!/bin/bash

if [ "$#" -eq 0 ]; then
  VERSION_MATRIX=('develop' '8.0-octane-develop' '8.0-fpm-develop' '7.4-fpm-develop')
else
  VERSION_MATRIX=("$@")
fi

EXTENSION_MATRIX=(
  'bcmath' 'curl' 'date' 'imagick' 'exif' 'fileinfo' 'hash' 'PDO' 'sockets'
  'json' 'mbstring' 'pdo_mysql' 'pdo_sqlite' 'sqlite3' 'zip' 'pcntl' 'redis'
  'swoole' 'posix' 'gd' 'mongodb'
)

for version in "${VERSION_MATRIX[@]}"
do
  # we pull the image fresh if this is not a develop (local) version.
  if [[ $version != *"develop"* ]]; then
    docker pull "own3d/laravel-docker:$version"
  fi

  for extension in "${EXTENSION_MATRIX[@]}"
  do
    command="$command if(!extension_loaded('$extension')) { echo 'ERROR: Extension $extension on $version is missing.' . PHP_EOL;}"
  done

  command="$command echo 'upload_max_filesize: ' . ini_get('upload_max_filesize') . PHP_EOL;"
  command="$command echo 'post_max_size: ' . ini_get('post_max_size') . PHP_EOL;"

  docker run -it --rm "own3d/laravel-docker:$version" php -r "$command"
done