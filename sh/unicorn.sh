
pin_2010_dir=`dirname $0`/..

user_auth_dir=$pin_2010_dir/sites/pin-user-auth
user_auth_pid=/web/2010/pids/unicorn-user-auth.pid

mev6_dir=$pin_2010_dir/sites/pin-mev6
mev6_pid=/web/2010/pids/unicorn-mev6.pid

uni_schedule_dir=$pin_2010_dir/sites/pin-uni-schedule
uni_schedule_pid=/web/2010/pids/unicorn-uni-schedule.pid

sh_dir=`dirname $0`
. $sh_dir/function.sh
. /etc/rc.status
rails_env=$(get_rails_env)

  case "$1" in
    user)
     cd $user_auth_dir
     pid=$user_auth_pid
     echo "user_auth_dir"
    ;;
    mev6)
     cd $mev6_dir
     pid=$mev6_pid
     echo "mev6"
    ;;
    schedule)
     cd $uni_schedule_dir
     pid=$uni_schedule_pid
     echo "schedule"
    ;;
    *)
    echo "$1"
    echo "tip:(user|mev6|schedule)"
    exit 5
    ;;
  esac
echo $rails_env
echo `pwd`
case "$2" in
	start)
        assert_process_from_pid_file_not_exist $pid
	echo "start"
	unicorn_rails -c config/unicorn.rb -D -E $rails_env
	rc_status -v
	;;
	stop)
	echo "stop"
	kill `cat $pid`
	rc_status -v	
	;;
	usr2_stop)
	echo "usr2_stop"
        kill -USR2 `cat $pid`
        rc_status -v
	;;
	restart)
	echo "restart"
	cd $sh_dir
	$0 "$1" stop
	sleep 1
	$0 "$1" start
	;;
	*)
	echo "tip:(start|stop|restart|usr2_stop)"
	exit 5
	;;
esac
exit 0

