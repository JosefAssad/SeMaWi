FROM debian:10.2
MAINTAINER Josef Assad <josef@josefassad.com>

ENV DEBIAN_FRONTEND noninteractive

# Get stack up
RUN apt-get update && \
	apt-get -y install mariadb-client apache2 curl php git unzip \
	php-mysql php-pgsql libapache2-mod-php virtualenv cron freetds-bin \
	tdsodbc php-odbc unixodbc odbcinst graphviz graphviz-dev imagemagick \
	libxml2-dev libxslt1-dev zlib1g-dev python2.7 python-dev gcc \
	php-mbstring php-xml php-curl && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy over the Mediawiki configs needed
COPY LocalSettings.php /var/www/wiki/LocalSettings.php
COPY composer.local.json /tmp/composer.local.json
COPY semawi.ini /etc/php/7.3/apache2/conf.d/99-semawi.ini
COPY db.sql /tmp/db.sql
ADD 001-semawi.conf /etc/apache2/sites-available/001-semawi.conf

# Installing the GC2 daemon
COPY scripts/installgc2daemon.sh /opt/installgc2daemon.sh
COPY scripts/syncgc2.sh /opt/syncgc2.sh
COPY gc2 /opt/gc2
RUN sh /opt/installgc2daemon.sh

# Copy over the apache wrapper
COPY scripts/entrypoint.sh /usr/local/bin/

# Start up apache
env APACHE_RUN_USER    www-data
env APACHE_RUN_GROUP   www-data
env APACHE_PID_FILE    /var/run/apache2.pid
env APACHE_RUN_DIR     /var/run/apache2
env APACHE_LOCK_DIR    /var/lock/apache2
env APACHE_LOG_DIR     /var/log/apache2
env LANG               C

EXPOSE 80

# disable 000-default (localhost) & enable 001-semawi (semawi)
RUN a2dissite 000-default
RUN a2ensite 001-semawi

CMD ["/usr/local/bin/entrypoint.sh"]
