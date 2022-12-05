#!/bin/bash
if [ $# -eq 0 ]
  then
    tag='latest'
  else
    tag=$1
fi
if [ $tag != 'latest' ]
then
  echo 'Build from from tag'
  docker build -f docker/${tag}/Dockerfile -t jkaninda/laravel-php-fpm:$tag .
else
 echo 'Build latest'
 docker build -f docker/8.1/Dockerfile -t jkaninda/laravel-php-fpm:$tag .
 
fi

