FROM php:7.2-fpm
ENV WORKDIR=/var/www
ENV STORAGE_DIR=/var/www/storage
# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmemcached-dev \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    librdkafka-dev \
    libpq-dev \
    openssh-server \
    zip \
    unzip \
    supervisor \
    sqlite3  \
    nano \
    cron

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Kafka 
RUN git clone https://github.com/arnaud-lb/php-rdkafka.git\
    && cd php-rdkafka \
    && phpize \
    && ./configure \
    && make all -j 5 \
    && make install 

# Install Rdkafka and enable it
RUN docker-php-ext-enable rdkafka \
     && cd .. \
    && rm -rf /php-rdkafka

# Install PHP extensions zip, mbstring, exif, bcmath, intl
RUN docker-php-ext-configure gd
RUN docker-php-ext-install  zip mbstring exif pcntl bcmath -j$(nproc) gd intl


# Install Redis and enable it
RUN pecl install redis  && docker-php-ext-enable redis



# Install the php memcached extension
RUN pecl install memcached && docker-php-ext-enable memcached

# Install the PHP pdo_mysql extention
RUN docker-php-ext-install pdo_mysql

# Install the PHP pdo_pgsql extention
RUN docker-php-ext-install pdo_pgsql


# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
# Copy php.ini file
COPY php.ini   $PHP_INI_DIR/conf.d/

# Install Laravel Envoy
RUN composer global require "laravel/envoy=~1.0"
# Set working directory
WORKDIR $WORKDIR

COPY ./entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN ln -s /usr/local/bin/entrypoint.sh /

ENTRYPOINT ["entrypoint.sh"]



RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data

RUN chmod 755 $WORKDIR


EXPOSE 9000
# entrypoint
CMD [ "entrypoint" ]
