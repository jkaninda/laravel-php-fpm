### 🐳 **Docker Image: Laravel PHP-FPM**  

A **ready-to-use container** designed for running PHP-based applications, including Laravel microservices.
This Docker image comes with **PHP-FPM**, offering a robust foundation for your projects with built-in support for essential extensions and configurations.

[![Build](https://github.com/jkaninda/laravel-php-fpm/actions/workflows/build.yml/badge.svg)](https://github.com/jkaninda/laravel-php-fpm/actions/workflows/build.yml)
[![Tests](https://github.com/jkaninda/laravel-php-fpm/actions/workflows/tests.yml/badge.svg)](https://github.com/jkaninda/laravel-php-fpm/actions/workflows/tests.yml)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/jkaninda/laravel-php-fpm?style=flat-square)
![Docker Pulls](https://img.shields.io/docker/pulls/jkaninda/laravel-php-fpm?style=flat-square)

<p align="center">
  <a href="https://github.com/jkaninda/laravel-php-fpm">
    <img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Logo">
  </a>
  </p>

#### **Features**  
- **PHP Application Support**: Optimized to run Laravel or any PHP-based applications.  
- **Integrated Extensions**:  
  - **Database**: MySQL and PostgreSQL.  
  - **Caching**: Redis and Memcached.  
  - **Messaging**: Kafka for event-driven architecture.  
  - **Task Scheduling**: Laravel Scheduler and Cron jobs support.  
- **Custom Configuration**: Pre-configured with sensible defaults, allowing seamless customization.  
- **Event Handling**: Support for advanced event-driven processes.  
- **Optimized for Microservices**: Built with modern PHP microservices in mind.  

This image is ideal for developers looking for a streamlined, high-performance solution to deploy PHP applications with essential tools already integrated.


## Links:
- [Docker Hub](https://hub.docker.com/r/jkaninda/laravel-php-fpm)
- [Github](https://github.com/jkaninda/laravel-php-fpm)
---

## **Supported PHP Versions**
- 8.4  
- 8.3  
- 8.2  
- 8.1  
- 8.0  
- 7.4  
- 7.2  

---

## **Specifications**

### **PHP Extensions**
- Composer  
- OpenSSL  
- XML  
- PDO (MySQL and PostgreSQL)  
- Rdkafka  
- Redis  
- Mbstring  
- PCNTL  
- ZIP  
- GD  
- BCMath  
- Memcached  
- Opcache  

### **Additional Features**
- Laravel Cron Jobs  
- Laravel Scheduler  
- Supervisord  
- Node.js and NPM  

---

## **Getting Started**

### **Simple Docker-Compose Example**
```yaml
services:
  php-fpm:
    image: jkaninda/laravel-php-fpm:latest
    container_name: php-fpm
    restart: unless-stopped
    user: www-data # For production
    volumes:
      - ./:/var/www/html
    networks:
      - default
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

### **Basic Commands**
- **Start Containers**  
  ```sh
  docker compose up -d
  ```

- **Create a Laravel Project**  
  ```sh
  docker compose exec php-fpm composer create-project --prefer-dist laravel/laravel .
  ```

- **Generate Application Key**  
  ```sh
  docker compose exec php-fpm php artisan key:generate
  ```

- **Create Storage Symlink**  
  ```sh
  docker compose exec php-fpm php artisan storage:link
  ```

- **Fix Permissions**  
  ```sh
  docker compose exec php-fpm chmod -R 777 storage bootstrap/cache
  ```

- **Run Laravel Migrations**  
  ```sh
  docker compose exec php-fpm php artisan migrate
  ```

- **Access the Container Shell**  
  ```sh
  docker exec -it php-fpm bash
  ```

---

## **Advanced Usage with Nginx**

### **Docker-Compose with Nginx**
Example of using a custom nginx config:

```yaml
version: '3'
services:
  php-fpm:
    image: jkaninda/laravel-php-fpm
    container_name: php-fpm
    restart: unless-stopped
    volumes:
      - ./:/var/www/html
    networks:
      - default

  nginx-server:
    image: nginx:alpine
    container_name: nginx-server
    restart: unless-stopped
    ports:
      - 80:80
    volumes:
      - ./:/var/www/html
      - ./default.conf:/etc/nginx/conf.d/default.conf
    environment:
      - DOCUMENT_ROOT=/var/www/html/public
      - CLIENT_MAX_BODY_SIZE=20M
      - PHP_FPM_HOST=php-fpm:9000
    networks:
      - default
```

### **Nginx Configuration (default.conf)**

```conf
server {
    listen 80;
    index index.php index.html;
    root /var/www/html/public;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php-fpm:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location / {
        try_files $uri $uri/ /index.php?$query_string;
        gzip_static on;
    }

    client_max_body_size 15M;
    server_tokens off;
    fastcgi_hide_header X-Powered-By;
}
```

---

## **Custom Build**

### **Dockerfile Example**
```Dockerfile
FROM jkaninda/laravel-php-fpm:8.3
# Copy Laravel project files
COPY . /var/www/html
VOLUME /var/www/html/storage
WORKDIR /var/www/html

# Fix permissions
RUN chown -R www-data:www-data /var/www/html

USER www-data
```

---

## **Supervisord Integration**

### **Adding Custom Supervisor Processes**
Place configurations in `/etc/supervisor/conf.d/`.  
Example Kafka consumer process:  
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

---

## **Custom PHP Configurations**
Place your custom `php.ini` file at:  
```
/usr/local/etc/php/conf.d/
```

---

## **Storage Permissions Fix**
If you encounter permission issues, run:  

```sh
docker compose exec php-fpm /bin/bash
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html/storage
```
---

### Explore Another Project: Goma Gateway

Are you building a microservices architecture?
Do you need a powerful yet lightweight API Gateway or a high-performance reverse proxy to secure and manage your services effortlessly?

Check out my other project — **[Goma Gateway](https://github.com/jkaninda/goma-gateway)**.

**Goma Gateway** is a high-performance, declarative API Gateway built for modern microservices. It comes with a rich set of built-in middleware, including:

* Basic, JWT, OAuth2, LDAP, and ForwardAuth authentication
* Caching and rate limiting
* Bot detection
* Built-in load balancing
* Simple configuration with minimal overhead
* ...and more!

**Protocol support:** REST, GraphQL, gRPC, TCP, and UDP

**Security:** Automatic HTTPS via Let’s Encrypt or use your own TLS certificates

Whether you're managing internal APIs or exposing public endpoints, **Goma Gateway** helps you do it efficiently, securely, and with minimal complexity.

---

### ⭐️ **Support the Project**  
If this project helped you, do not skip on giving it a star. Thanks!

