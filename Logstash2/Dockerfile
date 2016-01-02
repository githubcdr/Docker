FROM sebp/elk

ENV ES_HOME /usr/share/elasticsearch
WORKDIR ${ES_HOME}

RUN bin/plugin install royrusso/elasticsearch-HQ
RUN bin/plugin install logstash-input-beats
RUN bin/plugin install lmenezes/elasticsearch-kopf/2.0/v2.1.1
RUN cd /tmp \
    && curl -L -O http://download.elastic.co/beats/dashboards/beats-dashboards-1.0.1.tar.gz \
    && tar xzvf beats-dashboards-1.0.1.tar.gz \
    && cd beats-dashboards-1.0.1/ \
    && ./load.sh
