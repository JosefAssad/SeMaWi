FROM debian:10.2 AS composer-maker
ARG SMW_VERSION
ARG SRF_VERSION
ARG SFS_VERSION
RUN apt-get update && apt-get install -f -y gettext-base
COPY composer.local.json /tmp/composer.pre.json
RUN envsubst "\$SMW_VERSION,\$SRF_VERSION,\$SFS_VERSION" \
	< /tmp/composer.pre.json \
	> /tmp/composer.local.json

FROM debian:10.2
MAINTAINER Josef Assad <josef@josefassad.com>

# main image builder
ENV DEBIAN_FRONTEND noninteractive
# Get stack up
RUN apt-get update && \
	apt-get -y install mariadb-client apache2 curl php git unzip \
	php-mysql php-pgsql libapache2-mod-php freetds-bin \
	tdsodbc php-odbc unixodbc odbcinst graphviz graphviz-dev imagemagick \
	libxml2-dev libxslt1-dev zlib1g-dev supervisor python3 \
	python3-distutils php-mbstring php-xml php-curl php-intl plantuml && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy over the Mediawiki configs needed
COPY --from=composer-maker /tmp/composer.local.json /tmp/composer.local.json
COPY LocalSettings.php /tmp/LocalSettings.php
COPY semawi.ini /etc/php/7.3/apache2/conf.d/99-semawi.ini
COPY struktur.xml /tmp/struktur.xml
ADD 001-semawi.conf /etc/apache2/sites-available/001-semawi.conf

# Copy over the apache wrapper
COPY scripts/entrypoint.sh /usr/local/bin/

# Deploy supervisord configuration
COPY supervisord.conf /etc/supervisor/conf.d/semawi.conf

# and the data seeding helper script
COPY scripts/loaddata.sh /usr/local/bin/loaddata.sh

# install the semawi-runner
RUN curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
RUN python3 /tmp/get-pip.py
COPY SemawiRunner /tmp/SemawiRunner
RUN pip install /tmp/SemawiRunner
RUN pip install gunicorn

# Start up apache
env APACHE_RUN_USER    www-data
env APACHE_RUN_GROUP   www-data
env APACHE_PID_FILE    /var/run/apache2.pid
env APACHE_RUN_DIR     /var/run/apache2
env APACHE_LOCK_DIR    /var/lock/apache2
env APACHE_LOG_DIR     /var/log/apache2
env LANG               C

EXPOSE 80 5000

# disable 000-default (localhost) & enable 001-semawi (semawi)
RUN a2dissite 000-default
RUN a2ensite 001-semawi

WORKDIR /var/www/wiki/

HEALTHCHECK --interval=1m --timeout=10s --start-period=2m --retries=3 \
	CMD curl --fail http://127.0.0.1/ || exit 1

CMD ["/usr/bin/supervisord", "-n"]
