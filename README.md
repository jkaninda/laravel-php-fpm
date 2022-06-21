![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/jkaninda/laravel-php-fpm?style=flat-square)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/jkaninda/laravel-php-fpm?style=flat-square)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/jkaninda/laravel-php-fpm?style=flat-square)
![Docker Pulls](https://img.shields.io/docker/pulls/jkaninda/laravel-php-fpm?style=flat-square)

# Laravel PHP-FPM Docker image

> 🐳 Docker image for a PHP-FPM container crafted to run Laravel or any php based applications.

- [Docker Hub](https://hub.docker.com/r/jkaninda/laravel-php-fpm)

## Specifications:

* PHP 8.1 / 8.0 / 7.4 / 7.2
* Composer
* OpenSSL PHP Extension
* XML PHP Extension
* PDO PHP Extension
* Rdkafka PHP Extension
* Redis PHP Extension
* Mbstring PHP Extension
* PCNTL PHP Extension
* ZIP PHP Extension
* GD PHP Extension
* BCMath PHP Extension
* Memcached
* Laravel Cron Job
* Laravel Schedule
* Laravel Envoy
* Supervisord

## Simple docker-compose usage:

```yml
version: '3'
services:
    php-fpm:
        image: jkaninda/laravel-php-fpm:<tagname> or latest
        container_name: php-fpm
        restart: unless-stopped      
        volumes:
        #Project root
            - ./:/var/www/
            - ~/.ssh:/root/.ssh # If you use private CVS

        networks:
            - default #if you're using networks between containers

```
## Laravel `artisan` command usage:
### Open php-fpm
```sh
docker-compose exec php-fpm /bin/bash

```

### Laravel migration
```sh
php atisan  migrate

```
## Example Laravel-php-fpm with nginx:
### docker-compose.yml
```yml
version: '3'
services:
    php-fpm:
        image: jkaninda/laravel-php-fpm
        container_name: php-fpm
        working_dir: /var/www #Optional If you want to use  a custom directory
        restart: unless-stopped     
        volumes:
        #Project root
            - ./:/var/www/
            - ~/.ssh:/root/.ssh # If you use private CVS
        environment:
           - APP_ENV=development # or production
           - WORKDIR=/var/www #Optional If you want to use  a custom directory
        networks:
            - default #if you're using networks between containers
    #Nginx server
    nginx-server:
    image: nginx:alpine
    container_name: nginx-server
    restart: unless-stopped
    ports:
      - 80:80
    volumes:
      - ./:/var/www
      - ./default.conf:/etc/nginx/conf.d/default.conf
    networks:
      - default

```
## Simple Nginx config file content
### default.conf

```conf

server {
    listen 80;
    index index.php index.html;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    ##Public directory
    root /var/www/public;
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        ## PHP FPM ( php-fpm:9000 ) or [servicename:9000]
        fastcgi_pass php-fpm:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        
    }
    client_max_body_size 15M;
    server_tokens off;

     # Hide PHP headers 
    fastcgi_hide_header X-Powered-By; 
    fastcgi_hide_header X-CF-Powered-By;
    fastcgi_hide_header X-Runtime;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
        gzip_static on;
    }
}

```
## Docker run
```sh
 docker-compose up -d

``` 

> P.S. please give a star if you like it :wink:


