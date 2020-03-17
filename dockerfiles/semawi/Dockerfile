ARG DEBIAN_VERSION=10.2
FROM debian:$DEBIAN_VERSION AS composer-maker
ARG SMW_VERSION
ARG SRF_VERSION
ARG SFS_VERSION
RUN apt-get update && apt-get install -f -y gettext-base
COPY composer.local.json /tmp/composer.pre.json
RUN envsubst "\$SMW_VERSION,\$SRF_VERSION,\$SFS_VERSION" \
	< /tmp/composer.pre.json \
	> /tmp/composer.local.json

FROM debian:$DEBIAN_VERSION
ARG SEMAWI_MW_MINOR_VERSION
ARG SEMAWI_MW_PATCH_VERSION
MAINTAINER Josef Assad <josef@josefassad.com>

# main image builder
ENV DEBIAN_FRONTEND noninteractive
# Get stack up
RUN apt-get update && \
	apt-get -y install mariadb-client apache2 curl php git unzip \
	php-mysql php-pgsql libapache2-mod-php \
	graphviz graphviz-dev imagemagick \
	libxml2-dev libxslt1-dev zlib1g-dev supervisor python3 \
	python3-distutils php-mbstring php-xml php-curl php-intl plantuml && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy over the configs needed
COPY semawi.ini /etc/php/7.3/apache2/conf.d/99-semawi.ini
COPY struktur.xml /tmp/struktur.xml
ADD 001-semawi.conf /etc/apache2/sites-available/001-semawi.conf

# Copy over the apache wrapper
COPY scripts/runserver.sh /usr/local/bin/

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
RUN a2enmod headers

# Install php composer
WORKDIR /usr/local/bin/
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar composer

WORKDIR /var/www/wiki/

# Install Mediawiki and extensions
RUN curl -o /tmp/mediawiki.tar.gz \
	https://releases.wikimedia.org/mediawiki/1.$SEMAWI_MW_MINOR_VERSION/mediawiki-1.$SEMAWI_MW_MINOR_VERSION.$SEMAWI_MW_PATCH_VERSION.tar.gz && \
	tar xvf /tmp/mediawiki.tar.gz -C /var/www/wiki/ --strip 1
COPY LocalSettings.php /tmp/LocalSettings.php
COPY --from=composer-maker /tmp/composer.local.json /var/www/wiki/composer.local.json
RUN composer global require hirak/prestissimo
RUN composer update --no-dev
WORKDIR /var/www/wiki/extensions/SyntaxHighlight_GeSHi/
RUN composer update --no-dev

# Install extensions
WORKDIR /var/www/wiki/extensions/
# headertabs
RUN git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/HeaderTabs.git && \
	git -C HeaderTabs checkout -q REL1_$SEMAWI_MW_MINOR_VERSION
# MasonryMainPage
RUN git clone https://github.com/enterprisemediawiki/MasonryMainPage.git && \
	git -C MasonryMainPage checkout -q 9837244ccf70f3823e8f5366045e1637e65bd993
# Install ImagesLoaded
RUN git clone https://github.com/enterprisemediawiki/ImagesLoaded.git
# Install EditUser
RUN git clone https://github.com/wikimedia/mediawiki-extensions-EditUser.git && \
	mv mediawiki-extensions-EditUser EditUser && \
	git -C EditUser checkout -q REL1_$SEMAWI_MW_MINOR_VERSION
# Install ExternalData
RUN git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/ExternalData && \
	git -C ExternalData checkout -q REL1_$SEMAWI_MW_MINOR_VERSION
# Install RevisionSlider
RUN git clone https://github.com/wikimedia/mediawiki-extensions-RevisionSlider.git && \
	mv mediawiki-extensions-RevisionSlider RevisionSlider && \
   git -C RevisionSlider checkout -q REL1_$SEMAWI_MW_MINOR_VERSION
# Install OdbcDatabase
RUN git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/OdbcDatabase.git && \
	git -C OdbcDatabase checkout -q REL1_$SEMAWI_MW_MINOR_VERSION && \
	sed -i'' "s/public static function getSoftwareLink/public function getSoftwareLink/" \
	OdbcDatabase/OdbcDatabase.body.php
# Install Maintenance
RUN git clone https://github.com/wikimedia/mediawiki-extensions-Maintenance.git && \
	mv mediawiki-extensions-Maintenance Maintenance && \
	git -C Maintenance checkout -q REL1_$SEMAWI_MW_MINOR_VERSION
# Install PlantUML
RUN git clone https://github.com/pjkersten/PlantUML.git && \
	cp /usr/share/plantuml/plantuml.jar ./PlantUML/plantuml.jar

# fix ownership
RUN chown -R www-data:www-data /var/www/wiki/

HEALTHCHECK --interval=1m --timeout=10s --start-period=2m --retries=3 \
	CMD curl -A "semawi-healthcheck" --fail http://127.0.0.1/ || exit 1

CMD ["/usr/bin/supervisord", "-n"]
