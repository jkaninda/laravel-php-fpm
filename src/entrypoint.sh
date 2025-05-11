#!/bin/bash

set -e

# Logging functions
log() {
    local level=$1
    shift
    { set +x; } 2> /dev/null
    echo "[$level] $@"
}

info() {
    log "INFO" "$@"
}

warning() {
    log "WARNING" "$@"
}

fatal() {
    log "ERROR" "$@" >&2
    exit 1
}

# Banner
echo ""
echo "***********************************************************"
echo "   Starting LARAVEL PHP-FPM Container                      "
echo "***********************************************************"

# Check if the artisan file exists
ARTISAN_PATH="/var/www/html/artisan"
if [[ -f "$ARTISAN_PATH" ]]; then
    info "Artisan file found, creating Laravel supervisor config..."

    # Create Laravel Supervisor config
    SUPERVISOR_TASK="/etc/supervisor/conf.d/laravel-worker.conf"
    cat > "$SUPERVISOR_TASK" <<EOF
[program:Laravel-scheduler]
process_name=%(program_name)s_%(process_num)02d
command=/bin/sh -c "while true; do php $ARTISAN_PATH schedule:run --verbose --no-interaction & sleep 60; done"
autostart=true
autorestart=true
numprocs=1
user=$USER_NAME
stdout_logfile=/var/log/laravel_scheduler.out.log
redirect_stderr=true

[program:Laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php $ARTISAN_PATH queue:work --sleep=3 --tries=3
autostart=true
autorestart=true
numprocs=$LARAVEL_PROCS_NUMBER
user=$USER_NAME
redirect_stderr=true
stdout_logfile=/var/log/laravel_worker.log
EOF

    info "Laravel supervisor config created at $SUPERVISOR_TASK"
else
    info "Artisan file not found at $ARTISAN_PATH"
fi

# Check if custom php.ini file exists
PHP_INI_SOURCE="/var/www/html/conf/php/php.ini"
PHP_INI_TARGET="$PHP_INI_DIR/conf.d/php.ini"

if [[ -f "$PHP_INI_SOURCE" ]]; then
    cp "$PHP_INI_SOURCE" "$PHP_INI_TARGET"
    info "Custom php.ini file found and copied to $PHP_INI_TARGET"
else
    info "Custom php.ini file not found at $PHP_INI_SOURCE"
    info "To use a custom php.ini file, place it at $PHP_INI_SOURCE"
fi

# Start Supervisor
supervisord -c /etc/supervisor/supervisord.conf