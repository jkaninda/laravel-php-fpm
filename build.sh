#!/bin/bash
# Usage: ./build.sh [php-version] (default: 8.5)
#        ./build.sh 8.4-alpine
set -e
tag=${1:-8.5}
version=${tag%-alpine}

if [ -f "src/docker/${version}/Dockerfile" ]; then
  echo "Build legacy image ${tag}"
  docker build -f "src/docker/${version}/Dockerfile" -t "jkaninda/laravel-php-fpm:${tag}" .
elif [ "${tag}" != "${version}" ]; then
  echo "Build ${tag}"
  docker build --build-arg phpVersion="${version}" -f src/docker/Dockerfile.alpine -t "jkaninda/laravel-php-fpm:${tag}" .
else
  echo "Build ${tag}"
  docker build --build-arg phpVersion="${version}" -f src/docker/Dockerfile -t "jkaninda/laravel-php-fpm:${tag}" .
fi
