#! /bin/sh

root_dir=`pwd`

processor_pid=/web/2010/pids/mindmaps_lucene_service.pid

log_file=/web/2010/logs/mindmaps_lucene_service.log

. /etc/rc.status
case "$1" in
        start)
                echo "mindmaps_lucene_service start"
                java -jar $root_dir/java/lucene-for-notes/dist/lucene-for-notes.jar mindmaps 1> $log_file 2> $log_file & 
                echo $! > $processor_pid
                rc_status -v
        ;;
        stop)
                echo "mindmaps_lucene_service stop"
                kill `cat $processor_pid`
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


