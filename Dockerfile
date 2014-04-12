# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:0.9.9
MAINTAINER cODAR "me@codar.nl"

# Set correct environment variables.
ENV	HOME /root
ENV	LANG en_US.UTF-8
ENV	LC_ALL en_US.UTF-8
ENV	DEBIAN_FRONTEND	noninteractive

# set sane locale
RUN	locale-gen en_US.UTF-8

# Use baseimage-docker's init system.
CMD	["/sbin/my_init"]

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
# RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# prep apt-get
RUN	sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN	echo "root:yoleaux" | chpasswd

#RUN	DEBIAN_FRONTEND=noninteractive \
RUN apt-get -y update \
	&& apt-get -y install software-properties-common python-software-properties \
	&& add-apt-repository -y ppa:chris-lea/redis-server \
	&& apt-get -y update \
	&& apt-get -y upgrade \
	&& apt-get -y install openjdk-7-jre-headless redis-server wget mc tcpdump

# elasticsearch
RUN	cd /tmp \
	&& wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.0.deb \
	&& dpkg -i /tmp/elasticsearch-1.1.0.deb \
	&& /usr/share/elasticsearch/bin/plugin -install karmi/elasticsearch-paramedic \
	&& /usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head \
	&& echo "cluster.name: logstash" >> /etc/elasticsearch/elasticsearch.yml

# logstash
RUN	cd /tmp \
	&& wget https://download.elasticsearch.org/logstash/logstash/logstash-1.4.0.tar.gz \
	&& mkdir /apps \
	&& cd /apps \
	&& tar zxf /tmp/logstash-1.4.0.tar.gz \
	&& ln -s logstash-1.4.0 logstash \
	&& mkdir /etc/logstash

# services
RUN mkdir /etc/service/redis-server \
	&& mkdir /etc/service/elasticsearch \
	&& mkdir /etc/service/logstash-shipper \
	&& mkdir /etc/service/logstash-indexer \
	&& mkdir /etc/service/logstash-web

# services run files
ADD	redis-server.sh /etc/service/redis-server/run
ADD	elasticsearch.sh /etc/service/elasticsearch/run
ADD	logstash-shipper.sh /etc/service/logstash-shipper/run
ADD	logstash-indexer.sh /etc/service/logstash-indexer/run
ADD	logstash-web.sh /etc/service/logstash-web/run

# config
ADD	shipper.conf /etc/logstash/shipper.conf
ADD	indexer.conf /etc/logstash/indexer.conf

# Clean up APT when done.
RUN	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
