#! /bin/sh

unicorn_sh=/web1/unicorn.sh

case "$1" in
        start)
                $unicorn_sh config start
                $unicorn_sh user start
                $unicorn_sh workspace start
                $unicorn_sh discuss start
                $unicorn_sh bug start
                $unicorn_sh share start
                $unicorn_sh mindmap_editor start
                $unicorn_sh mindmap_image_cache start
                $unicorn_sh website start
        ;;
        stop)
                $unicorn_sh config stop
                $unicorn_sh user stop
                $unicorn_sh workspace stop
                $unicorn_sh discuss stop
                $unicorn_sh bug stop
                $unicorn_sh share stop
                $unicorn_sh mindmap_editor stop
                $unicorn_sh mindmap_image_cache stop
                $unicorn_sh website stop
        ;;
        usr2)
                $unicorn_sh config usr2
                $unicorn_sh user usr2
                $unicorn_sh workspace usr2
                $unicorn_sh discuss usr2
                $unicorn_sh bug usr2
                $unicorn_sh share usr2
                $unicorn_sh mindmap_editor usr2
                $unicorn_sh mindmap_image_cache usr2
                $unicorn_sh website usr2
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

