FROM sebp/elk:latest
WORKDIR /tmp

# install curator repo
#RUN curl https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
#RUN echo "deb http://packages.elastic.co/curator/3/debian stable main" > /etc/apt/sources.list.d/curator.list

#install moar shit
RUN apt-get update && apt-get install -qqy unzip git elasticsearch-curator

# remove old config and prepare new
RUN rm -vf /etc/logstash/conf.d/*.conf ; \
    mkdir /opt/logstash/databases

# geoIP
RUN curl -L -O http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz \
    && gunzip GeoIPASNum.dat.gz \
    && mv GeoIPASNum.dat /opt/logstash/databases/

RUN curl -L -O  http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz \
    && gunzip GeoLiteCity.dat.gz \
    && mv GeoLiteCity.dat /opt/logstash/databases/

# Download GROK patterns
RUN git clone https://github.com/logstash-plugins/logstash-patterns-core.git \
    && cp -av /tmp/logstash-patterns-core/patterns/* /opt/logstash/patterns/

# update logstash plugins
#RUN /opt/logstash/bin/plugin update
#RUN /opt/logstash/bin/plugin install logstash-input-beats

# update elasticsearch plugins
RUN /usr/share/elasticsearch/bin/plugin install royrusso/elasticsearch-HQ
RUN /usr/share/elasticsearch/bin/plugin install lmenezes/elasticsearch-kopf/2.0/v2.1.1
RUN /usr/share/elasticsearch/bin/plugin install mobz/elasticsearch-head

# install filebeat support for kibana
RUN curl -L -O http://download.elastic.co/beats/dashboards/beats-dashboards-1.3.1.zip

# add support for cisco syslog
ADD files/logstash.conf /etc/logstash/conf.d/

# TODO, add geoIP data, kibana dashboards at runtime

# cleanup
#RUN rm /etc/logstash/conf.d/01-lumberjack-input.conf
