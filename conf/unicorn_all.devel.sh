#! /bin/sh

unicorn_sh=/web1/unicorn.sh

case "$1" in
        start)
                $unicorn_sh user start
                $unicorn_sh workspace start
                $unicorn_sh discuss start
                $unicorn_sh bug start
                $unicorn_sh share start
                $unicorn_sh mindmap_image_cache start
                $unicorn_sh website start
		$unicorn_sh notes start
		$unicorn_sh mev6 start
        ;;
        stop)
                $unicorn_sh user stop
                $unicorn_sh workspace stop
                $unicorn_sh discuss stop
                $unicorn_sh bug stop
                $unicorn_sh share stop
                $unicorn_sh mindmap_image_cache stop
                $unicorn_sh website stop
		$unicorn_sh notes stop
		$unicorn_sh mev6 stop
        ;;
        usr2_stop)
                $unicorn_sh user usr2_stop
                $unicorn_sh workspace usr2_stop
                $unicorn_sh discuss usr2_stop
                $unicorn_sh bug usr2_stop
                $unicorn_sh share usr2_stop
                $unicorn_sh mindmap_image_cache usr2_stop
                $unicorn_sh website usr2_stop
		$unicorn_sh notes usr2_stop
		$unicorn_sh mev6 usr2_stop
        ;;
        restart)
                $0 stop
                sleep 1
                $0 start
        ;;
        *)
                echo "tip:(start|stop|restart|usr2_stop)"
                exit 5
        ;;
esac


