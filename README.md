[![Build](https://github.com/jkaninda/laravel-php-fpm/actions/workflows/build.yml/badge.svg)](https://github.com/jkaninda/laravel-php-fpm/actions/workflows/build.yml)
[![Integration Test](https://github.com/jkaninda/laravel-php-fpm/actions/workflows/integration-tests.yml/badge.svg)](https://github.com/jkaninda/laravel-php-fpm/actions/workflows/integration-tests.yml)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/jkaninda/laravel-php-fpm?style=flat-square)
![Docker Pulls](https://img.shields.io/docker/pulls/jkaninda/laravel-php-fpm?style=flat-square)

<p align="center">
  <a href="https://github.com/jkaninda/laravel-php-fpm">
    <img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Logo">
  </a>
  </p>

# Laravel PHP-FPM Docker image

> 🐳 Full Docker image for a PHP-FPM container created to run Laravel or any php based applications.

> PHP Microservices ready Docker container image.

- [Docker Hub](https://hub.docker.com/r/jkaninda/laravel-php-fpm)
- [Github](https://github.com/jkaninda/laravel-php-fpm)


## PHP Version:
- 8.3
- 8.2
- 8.1
- 8.0
- 7.4
- 7.2
## Specifications:

* Composer
* OpenSSL PHP Extension
* XML PHP Extension
* PDO PHP Extension
* PDO Mysql
* PDO Pgsql
* Rdkafka PHP Extension
* Redis PHP Extension
* Mbstring PHP Extension
* PCNTL PHP Extension
* ZIP PHP Extension
* GD PHP Extension
* BCMath PHP Extension
* Memcached
* Opcache
* Laravel Cron Job
* Laravel Schedule
* Laravel Envoy
* Supervisord
* Node
* NPM

## Simple docker-compose usage:

```yml
version: '3'
services:
    php-fpm:
        image: jkaninda/laravel-php-fpm:latest
        container_name: php-fpm
        restart: unless-stopped
        user: www-data #Use www-data user for production usage     
        volumes:
        #Project root
            - ./src:/var/www/html
        networks:
            - default #if you're using networks between containers

```
## Docker:
### Run
```sh
 docker compose up -d
```
### Create Laravel project
```sh
docker compose exec php-fpm composer create-project --prefer-dist laravel/laravel .
```
### Artisan generate key
```sh
docker compose exec php-fpm php artisan key:generate
```
### Storage link
```sh
docker compose exec php-fpm php artisan storage:link
```
### Fix permissions
```sh
docker compose exec php-fpm chmod -R 777 storage bootstrap/cache
```
### Laravel migration
```sh
 docker compose exec php-fpm php artisan migrate
```
### 
```sh
docker exec -it php-fpm bash

```

## Configurations

- Supervisor config folder: /etc/supervisor/conf.d/
- PHP ini config foler /usr/local/etc/php/conf.d/

## Example Laravel-php-fpm with nginx:
### docker-compose.yml
```yml
services:
    php-fpm:
        image: jkaninda/laravel-php-fpm
        container_name: php-fpm
        restart: unless-stopped     
        volumes:
        #Project root
            - ./:/var/www/html
        networks:
            - default #if you're using networks between containers
    #Nginx server
    nginx-server:
     image: jkaninda/nginx-fpm:alpine
     container_name: nginx-server
     restart: unless-stopped
     ports:
      - 80:80
     volumes:
      - ./:/var/www/html
     environment:
       - DOCUMENT_ROOT=/var/www/html/public
       - CLIENT_MAX_BODY_SIZE=20M
       - PHP_FPM_HOST=php-fpm:9000 
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
    root /var/www/html/public;
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

## Advanced Laravel-php-fpm with nginx:
### docker-compose.yml
```yml
services:
    php-fpm:
        image: jkaninda/laravel-php-fpm
        container_name: php-fpm
        restart: unless-stopped     
        volumes:
        #Project root
            - ./:/var/www/html
            - ~/.ssh:/root/.ssh # If you use private CVS
            - ./php.ini:/usr/local/etc/php/conf.d/php.ini # Optional, your custom php init file
        environment:
           - APP_ENV=development # Optional, or production
           #- LARAVEL_PROCS_NUMBER=1 # Optional, Laravel queue:work process number
    #Nginx server
    nginx-server:
    image: nginx:alpine
    container_name: nginx-server
    restart: unless-stopped
    ports:
      - 80:80
    volumes:
      - ./:/var/www/html
      - ./default.conf:/etc/nginx/conf.d/default.conf
    networks:
      - default
volumes:
 storage-data: 
```

## Docker run
```sh
 docker compose up -d

``` 
## Build from base

Dockerfile
```Dockerfile
FROM jkaninda/laravel-php-fpm:8.3
# Copy laravel project files
COPY . /var/www/html
# Storage Volume
VOLUME /var/www/html/storage

WORKDIR /var/www/html

# Custom cache invalidation / optional
#ARG CACHEBUST=1
# Run composer install / Optional
#RUN composer install
# Fix permissions
RUN chown -R www-data:www-data /var/www/html

```
## Supervisord
### Add supervisor process in

> /etc/supervisor/conf.d/

In case you want to execute and maintain a task or process with supervisor.

Find below an example with Apache Kafka, when you want to maintain a consumer process.
### Example:
```conf
[program:kafkaconsume-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/html/artisan kafka:consumer
autostart=true
autorestart=true
numprocs=1
user=www-data
redirect_stderr=true
stdout_logfile=/var/www/html/storage/logs/kafka.log
```

### Custom php.ini
> /var/www/html/conf/php/php.ini

### Storage permision issue
```sh
 docker compose exec php-fpm /bin/bash 
 ```

```sh
 chown -R www-data:www-data /var/www/html
 ```

> chmod -R 775 /var/www/html/storage


> P.S. please give a star if you like it :wink:


