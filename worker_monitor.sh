#! /bin/sh
mindmap_image_cache_queue_worker_pid=/web/2010/pids/mindmap_image_cache_queue_worker.pid

mindmap_import_queue_worker_pid=/web/2010/pids/mindmap_import_queue_worker.pid

mindmap_input_queue_worker_pid=/web/2010/pids/mindmap_input_queue_worker.pid


# 判断 mindmap_image_cache_queue_worker 是否正常运行
if [ ! -f $mindmap_image_cache_queue_worker_pid ]; then
 ./mindmap_image_cache_queue_worker.sh start 
else
  count_1=`ps \`cat $mindmap_image_cache_queue_worker_pid\`|wc -l`
  if [ $count_1 = 1  ]; then
    ./mindmap_image_cache_queue_worker.sh start
  fi
fi

# 判断 mindmap_import_queue_worker 是否正常运行
if [ ! -f $mindmap_import_queue_worker_pid ]; then
  ./mindmap_import_queue_worker.sh start
else
  count_2=`ps \`cat $mindmap_import_queue_worker_pid\`|wc -l`
  if [ $count_2 = 1 ]; then
    ./mindmap_import_queue_worker.sh start
  fi
fi

# 判断 mindmap_input_queue_worker 是否正常运行
if [ ! -f $mindmap_input_queue_worker_pid ]; then
  ./mindmap_input_queue_worker.sh start
else
  count_3=`ps \`cat $mindmap_input_queue_worker_pid\`|wc -l`
  if [ $count_3 = 1 ]; then
    ./mindmap_input_queue_worker.sh start
  fi
fi


