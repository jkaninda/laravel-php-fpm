# Laravel PHP-FPM Docker image

Docker image for a php-fpm container crafted to run Laravel or any php based applications.

## Specifications:

* PHP 8.1 / 8.0 / 7.4
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
* Laravel Envoy
* Supervisor

## Simple docker-compose usage:

```yml
version: '3'
services:
    php-fpm:
        image: jkaninda/laravel-php-fpm:<Tagname> or latest
        container_name: php-fpm
        restart: unless-stopped      
        volumes:
        #Project root
            - ./:/var/www/
        networks:
            - default #if you're using networks between containers

```
## Laravel `artisan` command usage:
### Open php-fpm
```bash
docker-compose exec php-fpm /bin/bash

```

### Laravel migration
```bash
php atisan  migrate

```
