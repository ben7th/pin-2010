#! /bin/sh
case "$1" in
  start)
    echo "a_key start"
    ./service_sh/memcache.sh
    ./unicorn_management.sh start
    
    ./service_sh/feeds_lucene_service.sh start
    ./service_sh/mindmaps_lucene_service.sh start
    ./service_sh/resque_web_service.sh start

    ./worker_sh/mindmap_input_queue_resque_worker.sh start
    ./worker_sh/mindmap_image_cache_queue_resque_worker.sh start
    ./worker_sh/mindmap_import_queue_resque_worker.sh start
    ./worker_sh/channel_user_operation_queue_resque_worker.sh start
    ./worker_sh/follow_operation_queue_resque_worker.sh start
    ./worker_sh/feed_operation_queue_resque_worker.sh start
    ./worker_sh/send_tsina_status_queue_resque_worker.sh start
    ./worker_sh/user_tip_resque_queue_worker.sh start

    ./worker_sh/mindmap_import_queue_worker.sh start
    #./worker_sh/synchronous_message_from_tsina_worker.sh start
    ./worker_sh/wake_up_resque_worker.sh start

    ./unicorn.sh mindmap_image_cache start
    ./unicorn.sh mev6 start
    ./unicorn.sh user start
  ;;
  stop)
    echo "a_key stop"
    ./unicorn.sh user stop
    ./unicorn.sh mev6 stop
    ./unicorn.sh mindmap_image_cache stop

    ./worker_sh/mindmap_input_queue_resque_worker.sh stop
    ./worker_sh/mindmap_image_cache_queue_resque_worker.sh stop
    ./worker_sh/mindmap_import_queue_resque_worker.sh stop
    ./worker_sh/channel_user_operation_queue_resque_worker.sh stop
    ./worker_sh/follow_operation_queue_resque_worker.sh stop
    ./worker_sh/feed_operation_queue_resque_worker.sh stop
    ./worker_sh/send_tsina_status_queue_resque_worker.sh stop
    ./worker_sh/user_tip_resque_queue_worker.sh stop

    ./worker_sh/mindmap_import_queue_worker.sh stop
    ./worker_sh/wake_up_resque_worker.sh stop
    #./worker_sh/synchronous_message_from_tsina_worker.sh stop

    ./service_sh/memcache.sh
    ./service_sh/feeds_lucene_service.sh stop
    ./service_sh/mindmaps_lucene_service.sh stop
    ./service_sh/resque_web_service.sh stop

    ./unicorn_management.sh stop
  ;;
  *)
  echo "tip:(start|stop)"
  exit 5
  ;;
esac
exit 0
