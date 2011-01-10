kill `cat /tmp/memcached.pid`
memcached -d -m 256 -u root -P /tmp/memcached.pid
