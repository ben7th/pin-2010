

dir=`dirname $0`/../management
pid=/web/2010/pids/unicorn-management.pid

sh_dir=`dirname $0`
. $sh_dir/function.sh
. /etc/rc.status
rails_env=$(get_rails_env)
sh_dir_path=$(get_sh_dir_path)
cd $dir
case "$1" in
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
	$sh_dir_path/`basename $0` stop
	sleep 1 
	$sh_dir_path/`basename $0` start
	;;
	*)
	echo "tip:(start|stop|restart|usr2_stop)"
	exit 5
	;;
esac
exit 0

