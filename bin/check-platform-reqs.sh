#!/bin/bash

#
# Checks that required PHP extensions and ini settings are present in each image.
#
# Usage: ./bin/check-platform-reqs.sh [image-tag ...]
#
# Examples:
#   ./bin/check-platform-reqs.sh
#   ./bin/check-platform-reqs.sh 8.5-fpm-minimal-develop
#   ./bin/check-platform-reqs.sh 8.5-octane-minimal 8.5-fpm-minimal
#

RED='\e[38;5;196m'
GREEN='\e[38;5;46m'
CYAN='\e[38;5;51m'
ORANGE='\e[38;5;208m'
RESET='\e[0m'

if [ "$#" -eq 0 ]; then
  VERSION_MATRIX=('8.5-octane-minimal' '8.5-fpm-minimal' '8.4-octane-minimal' '8.4-fpm-minimal')
else
  VERSION_MATRIX=("$@")
fi

EXTENSION_MATRIX=(
  'bcmath' 'curl' 'date' 'imagick' 'exif' 'fileinfo' 'hash' 'PDO' 'sockets'
  'json' 'mbstring' 'pdo_mysql' 'pdo_sqlite' 'sqlite3' 'zip' 'pcntl' 'redis'
  'swoole' 'posix' 'gd' 'mongodb'
)

PASS=0
FAIL=0

echo -e "${ORANGE}own3d/laravel-docker — platform requirements check${RESET}"
echo ""

for version in "${VERSION_MATRIX[@]}"
do
  image="own3d/laravel-docker:$version"

  if [[ $version != *"develop"* ]]; then
    if ! docker pull "$image" --quiet > /dev/null 2>&1; then
      echo -e "  ${RED}SKIP${RESET}  $version — image not found"
      ((FAIL++)) || true
      continue
    fi
  fi

  # Build extension check PHP snippet
  ext_checks=""
  for extension in "${EXTENSION_MATRIX[@]}"; do
    ext_checks="${ext_checks}if(!extension_loaded('${extension}')){echo 'ERROR: ${extension} missing'.PHP_EOL;}"
  done

  # Extension checks work the same way for all image types (PHP CLI is always present)
  ext_errors=$(docker run --rm "$image" php -r "$ext_checks" 2>&1 | grep '^ERROR:' || true)

  # Ini/config checks differ by image type
  if [[ $version == *"fpm"* ]]; then
    # php_admin_value in www.conf is only applied inside the FPM process, not via CLI.
    # Read the config file directly instead of relying on ini_get().
    ini_output=$(docker run --rm "$image" sh -c '
      WWW=/usr/local/etc/php-fpm.d/www.conf
      php -r "echo \"DEBUG: memory_limit(cli)=\".ini_get(\"memory_limit\").PHP_EOL;echo \"DEBUG: upload_max_filesize(cli)=\".ini_get(\"upload_max_filesize\").PHP_EOL;echo \"DEBUG: post_max_size(cli)=\".ini_get(\"post_max_size\").PHP_EOL;"
      grep -q "php_admin_value\[upload_max_filesize\] = 200M" "$WWW" \
        && echo "INFO: upload_max_filesize=200M (www.conf)" \
        || echo "ERROR: upload_max_filesize not set to 200M in www.conf"
      grep -q "php_admin_value\[post_max_size\] = 200M" "$WWW" \
        && echo "INFO: post_max_size=200M (www.conf)" \
        || echo "ERROR: post_max_size not set to 200M in www.conf"
    ' 2>&1)
  else
    # Octane: values are written to custom.ini, so ini_get() sees them from CLI too.
    ini_output=$(docker run --rm "$image" php -r '
      $m = ini_get("memory_limit");
      echo ($m === "512M" ? "INFO" : "ERROR") . ": memory_limit=" . $m . PHP_EOL;
      $u = ini_get("upload_max_filesize");
      echo ($u === "200M" ? "INFO" : "ERROR") . ": upload_max_filesize=" . $u . PHP_EOL;
      $p = ini_get("post_max_size");
      echo ($p === "200M" ? "INFO" : "ERROR") . ": post_max_size=" . $p . PHP_EOL;
    ' 2>&1)
  fi

  ini_errors=$(echo "$ini_output" | grep '^ERROR:' || true)
  ini_infos=$(echo "$ini_output"  | grep '^INFO:'  || true)
  all_errors=$(printf '%s\n%s' "$ext_errors" "$ini_errors" | grep '^ERROR:' || true)

  debug_lines=$(echo "$ini_output" | grep '^DEBUG:' || true)

  if [ -z "$all_errors" ]; then
    echo -e "  ${GREEN}PASS${RESET}  $version"
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      echo -e "        ${CYAN}${line#INFO:}${RESET}"
    done <<< "$ini_infos"
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      echo -e "        ${ORANGE}${line#DEBUG:}${RESET}"
    done <<< "$debug_lines"
    ((PASS++)) || true
  else
    echo -e "  ${RED}FAIL${RESET}  $version"
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      echo -e "        ${RED}${line}${RESET}"
    done <<< "$all_errors"
    ((FAIL++)) || true
  fi
done

echo ""
echo -e "  ${PASS} passed, ${FAIL} failed"
echo ""

[ "$FAIL" -eq 0 ]
