#!/bin/bash

echo ""
echo "***********************************************************"
echo "   Starting LARAVEL PHP-FPM Container                      "
echo "***********************************************************"

set -e
info() {
    { set +x; } 2> /dev/null
    echo '[INFO] ' "$@"
}
warning() {
    { set +x; } 2> /dev/null
    echo '[WARNING] ' "$@"
}
fatal() {
    { set +x; } 2> /dev/null
    echo '[ERROR] ' "$@" >&2
    exit 1
}
## Check if the artisan file exists
if [ -f /var/www/html/artisan ]; then
    info "Artisan file found, creating laravel supervisor config..."
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
    user=$USER_NAME
    stdout_logfile=/var/log/laravel_scheduler.out.log
    redirect_stderr=true
    
    [program:Laravel-worker]
    process_name=%(program_name)s_%(process_num)02d
    command=php /var/www/html/artisan queue:work --sleep=3 --tries=3
    autostart=true
    autorestart=true
    numprocs=$LARAVEL_PROCS_NUMBER
    user=$USER_NAME
    redirect_stderr=true
    stdout_logfile=/var/log/laravel_worker.log
EOF
info  "Laravel supervisor config created"
else
    info "artisan file not found"
fi

## Check if the supervisor config file exists
if [ -f /var/www/html/conf/worker/supervisor.conf ]; then
    info "additional supervisor config found"
    cp /var/www/html/conf/worker/supervisor.conf /etc/supervisor/conf.d/supervisor.conf
    else
    info "Supervisor.conf not found"
    info "If you want to add more supervisor configs, create config file in /var/www/html/conf/worker/supervisor.conf"
    info "Start supervisor with default config..."
    fi
## Check if php.ini file exists
if [ -f /var/www/html/conf/php/php.ini ]; then
    cp /var/www/html/conf/php/php.ini $PHP_INI_DIR/conf.d/
    info "Custom php.ini file found and copied in  $PHP_INI_DIR/conf.d/"
else
    info "Custom php.ini file not found"
    info "If you want to add a custom php.ini file, you add it in /var/www/html/conf/php/php.ini"
fi

supervisord -c /etc/supervisor/supervisord.conf
#exec "$@"