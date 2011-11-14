#! /bin/sh
case "$1" in
  start)
    echo "a_key start"
    ./service_sh/memcache.sh
    ./unicorn_management.sh start
    
    ./service_sh/feeds_lucene_service.sh start
    ./service_sh/mindmaps_lucene_service.sh start
    ./service_sh/resque_web_service.sh start

    ./worker_sh/resque_queue_workers_all.rb start
    ./worker_sh/wake_up_resque_worker.sh start

    ./unicorn.sh schedule start
    ./unicorn.sh mev6 start
    ./unicorn.sh user start
  ;;
  stop)
    echo "a_key stop"
    ./unicorn.sh user stop
    ./unicorn.sh mev6 stop
    ./unicorn.sh schedule stop

    ./worker_sh/wake_up_resque_worker.sh stop
    ./worker_sh/resque_queue_workers_all.rb stop 

    ./service_sh/feeds_lucene_service.sh stop
    ./service_sh/mindmaps_lucene_service.sh stop
    ./service_sh/resque_web_service.sh stop

    ./service_sh/memcache.sh
    ./unicorn_management.sh stop
  ;;
  *)
  echo "tip:(start|stop)"
  exit 5
  ;;
esac
exit 0
