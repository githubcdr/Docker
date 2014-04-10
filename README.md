Logstash for docker, need to write a nice blog for extra facebook likes.

First 'sharing is caring' commit evar!

Elasticsearch 1.0.1 / with head, paramedic plugin
Redis
Logstash 1.4
Persistent storage

Run like;

docker run --rm -v /tmp/elasticsearch:/var/lib/elasticsearch -p 2222:22 -p 9200:9200 -p 9300:9300 -p 9292:9292 -p 514:514 -p 514:514/udp cdrocker/logstash /sbin/my_init &

