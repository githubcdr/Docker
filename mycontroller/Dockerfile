FROM alpine:latest
MAINTAINER me codar nl
RUN apk add --update --no-cache s6 ca-certificates openjdk8-jre-base wget

ENV MYCONTROLLER_URL="https://github.com/mycontroller-org/mycontroller/releases/download/0.0.3.Alpha2/mycontroller-dist-standalone-0.0.3.Alpha2-bundle.tar.gz"

# fixups and permissions
RUN	cd /tmp \
	&& wget $MYCONTROLLER_URL -O mycontroller.tar.gz \
	&& tar zxf mycontroller.tar.gz -C /usr/local \
	&& rm mycontroller.tar.gz

# add files
COPY files/root/ /

# fixups
RUN	chmod +x /service/mycontroller/run

# ready to run, expose web and mqtt
EXPOSE 1883/tcp 8443/tcp

ENTRYPOINT ["/bin/s6-svscan","/service"]

