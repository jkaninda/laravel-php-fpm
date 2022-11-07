![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/jkaninda/laravel-php-fpm?style=flat-square)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/jkaninda/laravel-php-fpm?style=flat-square)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/jkaninda/laravel-php-fpm?style=flat-square)
![Docker Pulls](https://img.shields.io/docker/pulls/jkaninda/laravel-php-fpm?style=flat-square)

# Laravel PHP-FPM Docker image

> 🐳 Full Docker image for a PHP-FPM container created to run Laravel or any php based applications.

> PHP Microservices ready Docker container.

- [Docker Hub](https://hub.docker.com/r/jkaninda/laravel-php-fpm)
- [Github](https://github.com/jkaninda/laravel-php-fpm)


## Specifications:

* PHP 8.2 / 8.1 / 8.0 / 7.4 / 7.2
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
        volumes:
        #Project root
            - ./:/var/www/html
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
version: '3'
services:
    php-fpm:
        image: jkaninda/laravel-php-fpm
        container_name: php-fpm
        working_dir: /var/www/html #Optional, If you want to use  a custom directory
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
 docker-compose up -d

``` 
## Supervisord
### Add supervisor process file in
> /var/www/html/conf/worker/supervisor.conf

### Custom php.ini
> /var/www/html/conf/php/php.ini

### Storage permision issue
> docker-compose exec php-fpm /bin/bash 

> chown -R www-data:www-data /var/www/html/storage

> chmod -R 775 /var/www/html/storage


> P.S. please give a star if you like it :wink:


