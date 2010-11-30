sh_dir=`pwd`

cd sites/pin-mindmap-editor

case "$1" in
  production)
   echo "生产环境"
  ;;
  development)
   echo "开发环境"
  ;;
  *)
    echo "tip: ( production | development )"
    exit 5
  ;;
esac

case "$2" in
  config)
   rake ts:in RAILS_ENV="$1"
  ;;
  rebuild)
   rake ts:rebuild RAILS_ENV="$1"
  ;;
  start)
   rake ts:start RAILS_ENV="$1"
  ;;
  stop)
   rake ts:stop RAILS_ENV="$1"
  ;;
  restart)
   cd sh_dir
   $0 $1 $2 stop
   sleep 1
   cd sh_dir
   $0 $1 $2 start
  ;;
  *)
    echo "tip: ( config | rebuild | start | stop | restart)"
    exit 5
  ;;
esac

exit 0



