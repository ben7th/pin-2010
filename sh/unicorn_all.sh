#! /bin/sh

unicorn_sh=`dirname $0`/unicorn.sh

case "$1" in
        start)
                $unicorn_sh user start
                $unicorn_sh bug start
                $unicorn_sh mindmap_image_cache start
                $unicorn_sh mev6 start
        ;;
        stop)
                $unicorn_sh user stop
                $unicorn_sh bug stop
                $unicorn_sh mindmap_image_cache stop
                $unicorn_sh mev6 stop
        ;;
        usr2)
                $unicorn_sh user usr2_stop
                $unicorn_sh bug usr2_stop
                $unicorn_sh mindmap_image_cache usr2_stop
                $unicorn_sh mev6 usr2_stop
        ;;
        restart)
                $0 stop
                sleep 1
                $0 start
        ;;
        *)
                echo "tip:(start|stop|restart|usr2)"
                exit 5
        ;;
esac

