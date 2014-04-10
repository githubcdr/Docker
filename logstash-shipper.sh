#!/bin/sh
# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.
exec /apps/logstash/bin/logstash agent -f /etc/logstash/shipper.conf >> /var/log/logstash-shipper.log 2>&1
