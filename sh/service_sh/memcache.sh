kill `cat /tmp/memcached.pid`
memcached -d -m 512 -u root -P /tmp/memcached.pid
