#!/bin/sh
# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.
exec /sbin/setuser nobody /apps/logstash/bin/logstash-web >> /var/log/logstash-web.log 2>&1
