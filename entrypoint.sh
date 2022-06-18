#!/bin/sh
echo ""
echo "***********************************************************"
echo "          Starting LARAVEL PHP-FPM Docker Container        "
echo "***********************************************************"

set -e

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

[program:Laravel-scheduler]
process_name=%(program_name)s_%(process_num)02d
command=/bin/sh -c "while [ true ]; do (php /var/www/artisan schedule:run --verbose --no-interaction &); sleep 60; done"
autostart=true
autorestart=true
numprocs=1
user=root
stdout_logfile=/var/log/laravel_scheduler.out.log
redirect_stderr=true

[program:Laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/artisan queue:work --sleep=3 --tries=3
autostart=true
autorestart=true
numprocs=2
user=root
redirect_stderr=true
stdout_logfile=/var/log/laravel_worker.log

EOF

supervisord -c /etc/supervisor/supervisord.conf

