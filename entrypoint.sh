#!/bin/sh
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green

echo ""
echo "***********************************************************"
echo " Starting LARAVEL PHP-FPM Docker Container                 "
echo "***********************************************************"

set -e

## Create PHP-FPM worker process
TASK=/etc/supervisor/conf.d/worker.conf
touch $TASK
cat > "$TASK" <<EOF
[supervisord]
nodaemon=true
user=root

[program:php-fpm]
command=/usr/local/sbin/php-fpm
numprocs=1
autostart=true
autorestart=true
stderr_logfile=/var/log/php-fpm_consumer.err.log
stdout_logfile=/var/log/php-fpm_consumer.out.log
user=root
priority=100
EOF

## Check if the artisan file exists
if [ -f $WORKDIR/artisan ]; then
    echo "${Green} artisan file found, creating laravel supervisor config"
    ##Create Laravel Scheduler process
    TASK=/etc/supervisor/conf.d/laravel-worker.conf
    touch $TASK
    cat > "$TASK" <<EOF
    [supervisord]
    nodaemon=true
    user=root
    [program:Laravel-scheduler]
    process_name=%(program_name)s_%(process_num)02d
    command=/bin/sh -c "while [ true ]; do (php $WORKDIR/artisan schedule:run --verbose --no-interaction &); sleep 60; done"
    autostart=true
    autorestart=true
    numprocs=1
    user=root
    stdout_logfile=/var/log/laravel_scheduler.out.log
    redirect_stderr=true
    
    [program:Laravel-worker]
    process_name=%(program_name)s_%(process_num)02d
    command=php $WORKDIR/artisan queue:work --sleep=3 --tries=3
    autostart=true
    autorestart=true
    numprocs=2
    user=root
    redirect_stderr=true
    stdout_logfile=/var/log/laravel_worker.log
EOF
echo  "${Green} Laravel supervisor config created"
else
    echo  "${Red} artisan file not found"
fi
#check if storage directory exists
echo "Checking if storage directory exists"
    if [ -d "$STORAGE_DIR" ]; then
        echo "Directory $STORAGE_DIR  exist. Fixing permissions..."
        chown -R www-data:www-data $STORAGE_DIR
        chmod -R 775 $STORAGE_DIR
        echo  "${Green} Permissions fixed"

    else
        echo "${Red} Directory $STORAGE_DIR does not exist"
        echo "Fixing permissions from $WORKDIR"
        chown -R www-data:www-data $WORKDIR/storage
        chmod -R 775 $WORKDIR/storage
        echo  "${Green} Permissions fixed"
    fi

supervisord -c /etc/supervisor/supervisord.conf

