#! /bin/sh

. /etc/rc.status

self_dir=`dirname $0`

. $self_dir/function.sh
processor_pid=/web/2010/pids/follow_operation_queue_worker.pid

runner_rb=$self_dir/sites/pin-user-auth/script/runner

worker_rb=$self_dir/sites/pin-user-auth/script/follow_operation_queue_worker.rb

log_path=/web/2010/logs/follow_operation_queue_worker.log

if [ ! -f $log_path ]; then
  touch $log_path
fi

case "$1" in
  start)
    echo "start"
    assert_process_from_pid_file_not_exist $processor_pid
    ruby $runner_rb $worker_rb 1>>$log_path 2>>$log_path &
    echo $! > $processor_pid
    rc_status -v
  ;;
  stop)
    echo "stop"
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



