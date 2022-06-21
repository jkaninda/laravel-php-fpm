#!/usr/bin/env bash
if [ $# -eq 0 ]
  then
    tag='latest'
  else
    tag=$1
fi

#docker build -t jkaninda/laravel-php-fpm:$tag .
docker build -t jkaninda/php-fpm:$tag .
