FROM sebp/elk
WORKDIR /tmp

#install unzip
RUN apt-get install -qqy unzip git

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
RUN /opt/logstash/bin/plugin install logstash-input-beats

# update elasticsearch plugins
RUN /usr/share/elasticsearch/bin/plugin install royrusso/elasticsearch-HQ
RUN /usr/share/elasticsearch/bin/plugin install lmenezes/elasticsearch-kopf/2.0/v2.1.1

# install filebeat support for kibana
RUN curl -L -O http://download.elastic.co/beats/dashboards/beats-dashboards-1.1.1.zip

# add support for cisco syslog
ADD files/logstash.conf /etc/logstash/conf.d/

# TODO, add geoIP data, kibana dashboards at runtime

# cleanup
#RUN rm /etc/logstash/conf.d/01-lumberjack-input.conf
