# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:0.9.14
MAINTAINER cODAR "me@codar.nl"

# Versions
ENV     ELASTICSEARCH_URL https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.4.deb
ENV     LOGSTASH_URL https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz
ENV     LOGSTASH_VERSION logstash-1.4.2

# Set correct environment variables.
ENV     HOME /root
ENV     ROOTPASSWORD yoleaux
ENV     LANG en_US.UTF-8
ENV     LC_ALL en_US.UTF-8
ENV     DEBIAN_FRONTEND noninteractive

# set sane locale
RUN     locale-gen en_US.UTF-8

# Use baseimage-docker's init system.
CMD     ["/sbin/my_init"]

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
# RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# prep apt-get
RUN     echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup
RUN     echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache
RUN     sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN     echo "root:$ROOTPASSWORD" | chpasswd

# Preparations
RUN        apt-get -y update \
        && apt-get -y install software-properties-common python-software-properties \
        && add-apt-repository -y ppa:chris-lea/redis-server \
        && apt-get -y update \
        && apt-get -y upgrade \
        && apt-get -y install openjdk-7-jre-headless redis-server wget tcpdump

# elasticsearch
RUN        wget -q -O /tmp/elasticsearch.deb $ELASTICSEARCH_URL \
        && dpkg -i /tmp/elasticsearch.deb \
        && /usr/share/elasticsearch/bin/plugin -install karmi/elasticsearch-paramedic \
        && /usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head \
        && echo "cluster.name: logstash" >> /etc/elasticsearch/elasticsearch.yml

# logstash
RUN        wget -q -O /tmp/logstash.tar.gz $LOGSTASH_URL \
        && mkdir /apps \
        && cd /apps \
        && tar zxf /tmp/logstash.tar.gz \
        && ln -s $LOGSTASH_VERSION logstash

# filesystem
RUN        mkdir /etc/service/redis-server \
        && mkdir /etc/service/elasticsearch \
        && mkdir /etc/service/logstash-shipper \
        && mkdir /etc/service/logstash-indexer \
        && mkdir /etc/service/logstash-web \
        && mkdir /etc/logstash

# run files
ADD     redis-server.sh /etc/service/redis-server/run
ADD     elasticsearch.sh /etc/service/elasticsearch/run
ADD     logstash-shipper.sh /etc/service/logstash-shipper/run
ADD     logstash-indexer.sh /etc/service/logstash-indexer/run
ADD     logstash-web.sh /etc/service/logstash-web/run

# config
ADD     shipper.conf /etc/logstash/shipper.conf
ADD     indexer.conf /etc/logstash/indexer.conf
ADD     redis.conf /etc/redis/redis.conf

# Clean up APT when done.
RUN     apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
