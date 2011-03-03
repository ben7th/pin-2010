
user_auth_dir=/web/2010/pin-2010/sites/pin-user-auth
user_auth_pid=/web/2010/pids/unicorn-user-auth.pid

workspace_dir=/web/2010/pin-2010/sites/pin-workspace
workspace_pid=/web/2010/pids/unicorn-workspace.pid

discuss_dir=/web/2010/pin-2010/sites/pin-discuss
discuss_pid=/web/2010/pids/unicorn-discuss.pid

bug_dir=/web/2010/pin-2010/sites/pin-bugs
bug_pid=/web/2010/pids/unicorn-bugs.pid

share_dir=/web/2010/pin-2010/sites/pin-share
share_pid=/web/2010/pids/unicorn-share.pid


mindmap_image_cache_dir=/web/2010/pin-2010/apps/app-mindmap-image-cache
mindmap_image_cache_pid=/web/2010/pids/unicorn-mindmap-image-cache.pid

website_dir=/web/2010/pin-2010/sites/pin-website
website_pid=/web/2010/pids/unicorn-website.pid

notes_dir=/web/2010/pin-2010/sites/pin-notes
notes_pid=/web/2010/pids/unicorn-notes.pid

mev6_dir=/web/2010/pin-2010/sites/pin-mev6
mev6_pid=/web/2010/pids/unicorn-mev6.pid

sh_dir=`pwd`

. /etc/rc.status

  case "$1" in
    user)
     cd $user_auth_dir
     pid=$user_auth_pid
     echo "user_auth_dir"
    ;;
    workspace)
     cd $workspace_dir
     pid=$workspace_pid
     echo "workspace_dir"
    ;;
    discuss)
     cd $discuss_dir
     pid=$discuss_pid
     echo "discuss"
    ;;
    bug)
     cd $bug_dir
     pid=$bug_pid
     echo "bug"
    ;;
    share)
     cd $share_dir
     pid=$share_pid
     echo "share"
    ;;
    mindmap_editor)
     cd $mindmap_editor_dir
     pid=$mindmap_editor_pid
     echo "mindmap_editor"
    ;;
    mindmap_image_cache)
     cd $mindmap_image_cache_dir
     pid=$mindmap_image_cache_pid
     echo "mindmap_image_cache"
    ;;
    website)
     cd $website_dir
     pid=$website_pid
     echo "website"
    ;;
    notes)
     cd $notes_dir
     pid=$notes_pid
     echo "notes"
    ;;
    mev6)
     cd $mev6_dir
     pid=$mev6_pid
     echo "mev6"
    ;;
    *)
    echo "$1"
    echo "tip:(config|user|workspace|discuss|bug|share|mindmap_image_cache|website|notes|mev6)"
    exit 5
    ;;
  esac

case "$2" in
    start)
      echo "start"
      unicorn_rails -c config/unicorn.rb -D -E production
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


