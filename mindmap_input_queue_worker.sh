#! /bin/sh

. /etc/rc.status

self_dir=`dirname $0`

processor_pid=/web/2010/pids/mindmap_input_queue_worker.pid

runner_rb=$self_dir/sites/pin-mev6/script/runner

mq_rb=$self_dir/sites/pin-mev6/script/mindmap_input_queue_worker.rb

log_path=/web/2010/logs/mindmap_input_queue_worker.log

case "$1" in
  start)
    echo "start"
    ruby $runner_rb $mq_rb 1>>$log_path 2>>$log_path &
    echo $! > $processor_pid
    rc_status -v
  ;;
  stop)
    echo "stop"
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

