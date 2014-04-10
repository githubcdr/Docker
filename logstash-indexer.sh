#!/bin/sh
# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.
exec /sbin/setuser nobody /apps/logstash/bin/logstash agent -f /etc/logstash/indexer.conf >> /var/log/logstash-indexer.log 2>&1
