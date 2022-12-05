#!/bin/sh
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
echo ""
echo "***********************************************************"
echo " Starting LARAVEL PHP-FPM Docker Container                 "
echo "***********************************************************"

set -e

## Check if the artisan file exists
if [ -f /var/www/html/artisan ]; then
    echo "${Green} artisan file found, creating laravel supervisor config..."
    ##Create Laravel Scheduler process
    TASK=/etc/supervisor/conf.d/laravel-worker.conf
    touch $TASK
    cat > "$TASK" <<EOF
    [program:Laravel-scheduler]
    process_name=%(program_name)s_%(process_num)02d
    command=/bin/sh -c "while [ true ]; do (php /var/www/html/artisan schedule:run --verbose --no-interaction &); sleep 60; done"
    autostart=true
    autorestart=true
    numprocs=1
    user=www-data
    stdout_logfile=/var/log/laravel_scheduler.out.log
    redirect_stderr=true
    
    [program:Laravel-worker]
    process_name=%(program_name)s_%(process_num)02d
    command=php /var/www/html/artisan queue:work --sleep=3 --tries=3
    autostart=true
    autorestart=true
    numprocs=$LARAVEL_PROCS_NUMBER
    user=www-data
    redirect_stderr=true
    stdout_logfile=/var/log/laravel_worker.log
EOF
echo  "${Green} Laravel supervisor config created"
else
    echo  "${Red} artisan file not found"
fi

## Check if the supervisor config file exists
if [ -f /var/www/html/conf/worker/supervisor.conf ]; then
    echo "additional supervisor config found"
    cp /var/www/html/conf/worker/supervisor.conf /etc/supervisor/conf.d/supervisor.conf
    else
    echo "${Red} Supervisor.conf not found"
    echo "${Green} If you want to add more supervisor configs, create config file in /var/www/html/conf/worker/supervisor.conf"
    echo "${Green} Start supervisor with default config..."
    fi
## Check if php.ini file exists
if [ -f /var/www/html/conf/php/php.ini ]; then
    cp /var/www/html/conf/php/php.ini $PHP_INI_DIR/conf.d/
    echo "Custom php.ini file found and copied in  $PHP_INI_DIR/conf.d/"
else
    echo "Custom php.ini file not found"
    echo "If you want to add a custom php.ini file, you add it in /var/www/html/conf/php/php.ini"
fi

echo ""
echo "**********************************"
echo "     Starting Supervisord...     "
echo "***********************************"
supervisord -c /etc/supervisor/supervisord.conf

