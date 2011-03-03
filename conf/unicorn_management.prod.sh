

dir=/web/2010/pin-2010/management
pid=/web/2010/pids/unicorn-management.pid

sh_dir=`pwd`

. /etc/rc.status
cd $dir
case "$1" in
	start)
	echo "start"
	unicorn_rails -c config/unicorn.rb -D
	rc_status -v
	;;
	stop)
	echo "stop"
	kill `cat $pid`
	rm -rf $pid
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
	$0 stop
	sleep 1
	$0 start
	;;
	*)
	echo "tip:(start|stop|restart|usr2_stop)"
	exit 5
	;;
esac
exit 0

