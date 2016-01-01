Description:

- Logstash for docker, with redis shipper buffer, ready to run and collect all your base.

Versions:

- Elasticsearch latest (v1.3.4) / with head, paramedic plugin
- Redis
- Logstash latest (v1.4.2)
- Persistent storage optional
- Build on phusion/baseimage \0/

Usage:

- docker run --rm -v /tmp/elasticsearch:/var/lib/elasticsearch -p 2222:22 -p 9200:9200 -p 9300:9300 -p 9292:9292 -p 514:514 -p 514:514/udp cdrocker/logstash /sbin/my_init &
- ssh <dockerhost:2222> root:yoleaux
