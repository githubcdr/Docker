#!/bin/sh
# If you omit that part, the command will be run as root.
exec setuser redis /usr/bin/redis-server >>/var/log/redis.log 2>&1
