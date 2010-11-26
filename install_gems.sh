case "$1" in
  ui)
    cd gems/pie-ui
    rake manifest
    rake install
    echo "OK"
  ;;
  auth)
    cd gems/pie-auth
    rake manifest
    rake install
    echo "OK"
  ;;
  repo)
    cd gems/pie-repo
    rake manifest
    rake install
    echo "OK"
  ;;
  lib)
    cd gems/pie-service-lib
    rake manifest
    rake install
    echo "OK"
  ;;
  all)
    ./install_gems.sh ui
    ./install_gems.sh auth
    ./install_gems.sh repo
    ./install_gems.sh lib
  ;;
  *)
    echo "tip: ui|auth|repo|lib"
    exit 5
  ;;
esac
exit 0
