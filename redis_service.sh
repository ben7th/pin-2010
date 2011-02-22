#! /bin/sh

root_dir=`pwd`

processor_pid=/web/2010/pids/redis_service.pid

log_file=/web/2010/logs/redis_service.log

. /etc/rc.status
case "$1" in
        start)
                echo "redis_service start"
                cd $root_dir/../redis-2.0.4
                ./redis-server 1> $log_file 2> $log_file & 
                echo $! > $processor_pid
                rc_status -v
        ;;
        stop)
                echo "redis_service stop"
                kill -9 `cat $processor_pid`
                rm -rf $processor_pid
                rc_status -v
        ;;
        restart)
                $0 stop
                sleep 1
                $0 start
        ;;
        *)
                echo "tip:(start|stop|restart)"
                exit 5
        ;;
esac
exit 0


