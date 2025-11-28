# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:0.10.2
MAINTAINER cODAR "me _ codar.nl"

# Set correct environment variables.
ENV     HOME /root
ENV     ROOTPASSWORD yoleaux
ENV     LANG en_US.UTF-8
ENV     LC_ALL en_US.UTF-8
ENV     DEBIAN_FRONTEND noninteractive

# Used for fast setup of Qmail
ENV	MAILHOSTNAME mail.bendover.nl

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
        && apt-get -y upgrade \
        && apt-get -y install build-essential libssl-dev libmysqlclient-dev clamav clamav-freshclam clamav-daemon spamassassin dovecot-imapd dovecot-pop3d groff-base mc mysql-server wget telnet libpcre++-dev autoconf automake

RUN	groupadd -r nofiles \
	&& groupadd -r qmail \
	&& groupadd -r vchkpw \
	&& groupadd -r simscan \
	&& useradd -r -d /var/qmail/alias -s /sbin/nologin -p'*' alias \
	&& useradd -r -d /var/qmail -s /sbin/nologin -p'*' qmaild \
	&& useradd -r -d /var/qmail -s /sbin/nologin -p'*' qmaill \
	&& useradd -r -d /var/qmail -s /sbin/nologin -p'*' qmailp \
	&& useradd -r -d /var/qmail -s /sbin/nologin -p'*' qmailq \
	&& useradd -r -d /var/qmail -s /sbin/nologin -p'*' qmailr \
	&& useradd -r -d /var/qmail -s /sbin/nologin -p'*' qmails \
	&& useradd -r -s /bin/false -c "Simscan Content Filter" -p'*' simscan -g simscan \
	&& useradd -r -d /home/vpopmail -s /sbin/nologin -p'*' vpopmail \
	&& mkdir -p /var/log/qmail/qmail-smtpd \
	&& mkdir -p /var/log/qmail/qmail-send \
	&& chown -R qmaill:root /var/log/qmail \
	&& chmod -R 750 /var/log/qmail

# MySQL
RUN	/etc/init.d/mysql start \
	&& sleep 10 \
	&& echo "CREATE DATABASE vpopmail;" | mysql \
	&& echo "GRANT select,insert,update,delete,create,drop ON vpopmail.* TO vpopmail@localhost IDENTIFIED BY '$ROOTPASSWORD';" | mysql \
	&& echo "FLUSH PRIVILEGES;" | mysql

#RUN	/etc/init.d/mysql start
#RUN	sleep 10; echo "UPDATE mysql.user SET Password=PASSWORD('yoleaux') WHERE User='root';" | mysql
#DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
#DELETE FROM mysql.user WHERE User='';
#DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
#FLUSH PRIVILEGES;
#EOF
#RUN	/etc/init.d/mysql stop

# clamav
ADD     etc/clamav/clamd.conf /etc/clamav/clamd.conf
RUN	freshclam

# Qmail and dependencies
ADD	ucspi-tcp6-1.00.tgz /var/qmail/
RUN	chown -R root.root /var/qmail/net/ \
	&& cd /var/qmail/net/ucspi-tcp6-1.00/ \
	&& sleep 2; package/install

# qmail
ADD	qmail-1.03.tar.gz /usr/src/
ADD	qmail-1.03-jms1-7.10.patch /usr/src/qmail-1.03/
RUN	cd /usr/src/qmail-1.03 \
	&& patch < qmail-1.03-jms1-7.10.patch \
	&& make man \
	&& make setup check \
	&& ./config-fast $MAILHOSTNAME \
	&& ln -s /var/qmail/bin/sendmail /usr/sbin/sendmail

ADD	rc /var/qmail/
ADD	control /var/qmail/control/
ADD	etc/tcp.smtp /etc/tcp.smtp
RUN	cd /etc && tcprules tcp.smtp.cdb tcp.smtp.tmp < tcp.smtp

# ripmime
ADD	ripmime-1.4.0.10.tar.gz /usr/src/
RUN	cd /usr/src/ripmime-1.4.0.10 \
	&& make && make install

# Simscan
ADD	simscan-1.4.0.tar.gz /usr/src/
ADD	simscan-1.4.0-combined.3.patch /usr/src/simscan-1.4.0/
RUN	cd /usr/src/simscan-1.4.0 \
	&& patch < simscan-1.4.0-combined.3.patch \
	&& ./configure --enable-clamdscan=/usr/bin/clamdscan --enable-per-domain=y --enable-spam=y --enable-received=y --enable-regex=y --enable-clamavdb-path=/var/lib/clamav --enable-attach=y --enable-spam-hits=10 --enable-sigtool-path=/usr/bin/sigtool --enable-custom-smtp-reject=y \
	&& make \
	&& make install-strip \
	&& chgrp simscan /var/qmail/simscan \
	&& chmod g+s /var/qmail/simscan \
	&& usermod -a -G simscan clamav \
	&& /var/qmail/bin/simscanmk \
	&& /var/qmail/bin/simscanmk -g

# vpopmail
ADD	vpopmail-5.4.33.tar.gz /usr/src/
RUN	cd /usr/src/vpopmail-5.4.33 \
	&& ./configure --disable-roaming-users --enable-logging=p --enable-auth-module=mysql --disable-passwd --enable-clear-passwd --enable-many-domains --enable-auth-logging --enable-sql-logging --enable-valias --disable-mysql-limits \
	&& make \
	&& make install-strip \
	&& echo "localhost|0|vpopmail|$ROOTPASSWORD|vpopmail" > ~vpopmail/etc/vpopmail.mysql \
	&& chmod 770 /home/vpopmail

# perl CDB module
RUN	cpan -i CDB_File IO::Socket::IP Encode::Detect Mail::DKIM Digest::SHA1 Geo::IP

# MKVALIDRCPTO SCRIPT
ADD	mkvalidrcptto /usr/local/bin/
RUN	/usr/local/bin/mkvalidrcptto -c /var/qmail/control/validrcptto.cdb

# logstash
#RUN     mkdir -p /usr/src/qmail/ && cd /usr/src/qmail \
#	&& wget -q -O qmail.tar.xz $QMAIL_URL \
#        && tar Jvxf qmail.tar.xz \
#	&& rm -vf qmail.tar.xz

# run files
ADD     etc/service/qmail-send/run /etc/service/qmail-send/run
ADD     etc/service/qmail-smtpd/run /etc/service/qmail-smtpd/run
ADD     etc/service/spamd/run /etc/service/spamd/run
ADD     etc/service/clamd/run /etc/service/clamd/run
ADD     etc/service/mysqld/run /etc/service/mysqld/run
ADD     etc/service/dovecot/run /etc/service/dovecot/run


# Fix permissions
RUN	chmod +x /etc/service/spamd/run /etc/service/clamd/run /etc/service/mysqld/run /etc/service/dovecot/run /etc/service/qmail-smtpd/run /etc/service/qmail-send/run
RUN	sa-update -D
RUN	sa-compile -D
RUN	mkdir /var/run/clamav && chown clamav /var/run/clamav/
RUN	freshclam

# Clean up APT when done.
RUN     apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 25 993 994 110 143
