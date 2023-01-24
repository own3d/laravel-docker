#!/bin/bash

#
# This script is used to check the requirements for the different versions.
# It is used for local development.
#
# Usage: ./bin/check-platform-reqs.sh [dockerfile]
#
# Examples:
#   ./bin/check-platform-reqs.sh 8.2-fpm-minimal
#   ./bin/check-platform-reqs.sh 8.2-octane-minimal 8.2-fpm-minimal
#

echo -e "\e[38;5;208mWelcome to the own3d/laravel-docker check platform requirements script!\e[0m"
echo -e "\e[38;5;208mThis tool will help you check if your docker image is compatible with your\e[0m"
echo -e "\e[38;5;208mapplication requirements.\e[0m"
echo -e "\e[38;5;208m\e[0m"

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
  echo -e "\e[38;5;208mChecking requirements for $version...\e[0m"

  # we pull the image fresh if this is not a develop (local) version.
  if [[ $version != *"develop"* ]]; then
    echo -e "\e[38;5;208mPulling docker image for $version...\e[0m"
    docker pull "own3d/laravel-docker:$version"
  fi

  echo -e "\e[38;5;208mCreating extensions requirements for $version...\e[0m"
  for extension in "${EXTENSION_MATRIX[@]}"
  do
    command="$command if(!extension_loaded('$extension')) { echo 'ERROR: Extension $extension on $version is missing.' . PHP_EOL;}"
  done

  echo -e "\e[38;5;208mCreating ini requirements for $version...\e[0m"
  command="$command echo 'INFO: upload_max_filesize: ' . ini_get('upload_max_filesize') . PHP_EOL;"
  command="$command echo 'INFO: post_max_size: ' . ini_get('post_max_size') . PHP_EOL;"

  echo -e "\e[38;5;208mChecking all requirements for $version...\e[0m"
  result=$(docker run -it --rm "own3d/laravel-docker:$version" php -r "$command")

  echo ""
  echo -e "\e[38;5;208mResults are in for $version:\e[0m"
  # mark ERROR lines red and INFO lines cyan:
  echo -e "$result" | sed -e 's/ERROR: /\\e[38;5;196mERROR: /g' -e 's/INFO: /\\e[38;5;51mINFO: /g' | xargs -0 -I {} echo -e {}

  echo -e "\e[38;5;208mDone! Please compare the results for $version!\e[0m"
done