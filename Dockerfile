# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:0.9.9
MAINTAINER cODAR "me@codar.nl"

# Set correct environment variables.
ENV HOME /root
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND	noninteractive

# set sane locale
RUN locale-gen en_US.UTF-8

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
# RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# prep apt-get
#RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup
#RUN echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache
#RUN sed 's/main$/main universe/' -i /etc/apt/sources.list
#RUN echo "root:yoleaux" | chpasswd

#RUN	DEBIAN_FRONTEND=noninteractive \
RUN apt-get update
RUN apt-get -y install software-properties-common python-software-properties
