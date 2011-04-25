#! /bin/sh

root_dir=`dirname $0`

processor_pid=/web/2010/pids/resque_web_service.pid

log_file=/web/2010/logs/resque_web_service.log

. /etc/rc.status
. $root_dir/../function.sh
case "$1" in
        start)
                assert_process_from_pid_file_not_exist $processor_pid
                echo "resque_web_service start"
                resque-web -p 8282 --pid-file $processor_pid  1>> $log_file 2>> $log_file & 
                rc_status -v
        ;;
        stop)
                echo "resque_web_service stop"
                kill -9 `cat $processor_pid`
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


