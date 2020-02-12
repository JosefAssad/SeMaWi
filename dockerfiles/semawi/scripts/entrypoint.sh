#!/bin/bash

set -e

if [ ! -d "/var/www/wiki/extensions" ]; then

   LOCALSETTINGS="/var/www/wiki/LocalSettings.php"
   SED="/bin/sed"

   # Install Mediawiki
   curl -o /tmp/mediawiki.tar.gz \
   https://releases.wikimedia.org/mediawiki/1.$SEMAWI_MW_MINOR_VERSION/mediawiki-1.$SEMAWI_MW_MINOR_VERSION.$SEMAWI_MW_PATCH_VERSION.tar.gz
   tar xvf /tmp/mediawiki.tar.gz -C /var/www/wiki/ --strip 1
   chown -R root:root /var/www/wiki
   chown -R www-data:www-data /var/www/wiki/images/

   # wait for mysql container to be ready
   echo "Waiting for db to come online..."
   until mysqladmin -h semawi-mysql -u wiki -pwiki ping &>/dev/null; do
       echo -n "."; sleep 0.2
   done
   echo "DB is online!"

   # Run the install script
   echo "Executing install script..."
   /usr/bin/php \
       /var/www/wiki/maintenance/install.php \
       --dbserver semawi-mysql \
       --dbname wiki \
       --dbuser wiki \
       --dbpass wiki \
       --pass SeMaWiSeMaWi \
       SeMaWi \
       SeMaWi
   echo "Install script complete!"

   # copy the LocalSettings over
   cp /tmp/LocalSettings.php /var/www/wiki/LocalSettings.php

   # Install the dependencies
   mv /tmp/composer.local.json /var/www/wiki/composer.local.json
   chown www-data:www-data /var/www/wiki/composer.local.json

   # Install composer and run its dependencies
   cd /var/www/wiki/
   curl -sS https://getcomposer.org/installer | php
   /usr/bin/php /var/www/wiki/composer.phar global require hirak/prestissimo
   /usr/bin/php /var/www/wiki/composer.phar update

   # install GeSHi syntax highlighting
   cd /var/www/wiki/extensions/SyntaxHighlight_GeSHi/
   php /var/www/wiki/composer.phar update --no-dev
   # Install DataTransfer

   cd /var/www/wiki/extensions/
   git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/DataTransfer.git
   cd /var/www/wiki/extensions/DataTransfer
   git checkout -q REL1_$SEMAWI_MW_MINOR_VERSION

   # Install HeaderTabs
   cd /var/www/wiki/extensions/
   git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/HeaderTabs.git
   cd /var/www/wiki/extensions/HeaderTabs
   git checkout -q REL1_$SEMAWI_MW_MINOR_VERSION

   # Install MasonryMainPage
   cd /var/www/wiki/extensions/
   git clone https://github.com/enterprisemediawiki/MasonryMainPage.git
   cd MasonryMainPage
   git checkout -q 9837244ccf70f3823e8f5366045e1637e65bd993

   # Install ImagesLoaded
   cd /var/www/wiki/extensions/
   git clone https://github.com/enterprisemediawiki/ImagesLoaded.git

   # Install EditUser
   cd /var/www/wiki/extensions/
   git clone https://github.com/wikimedia/mediawiki-extensions-EditUser.git
   mv mediawiki-extensions-EditUser EditUser
   cd /var/www/wiki/extensions/EditUser
   git checkout -q REL1_$SEMAWI_MW_MINOR_VERSION

   # Install ExternalData
   cd /var/www/wiki/extensions/
   git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/ExternalData
   cd /var/www/wiki/extensions/ExternalData
   git checkout -q REL1_$SEMAWI_MW_MINOR_VERSION

   # Install RevisionSlider
   cd /var/www/wiki/extensions/
   git clone https://github.com/wikimedia/mediawiki-extensions-RevisionSlider.git
   mv mediawiki-extensions-RevisionSlider RevisionSlider
   cd /var/www/wiki/extensions/RevisionSlider
   git checkout -q REL1_$SEMAWI_MW_MINOR_VERSION

   # Install OdbcDatabase
   cd /var/www/wiki/extensions/
   git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/OdbcDatabase.git
   cd /var/www/wiki/extensions/OdbcDatabase
   git checkout -q REL1_$SEMAWI_MW_MINOR_VERSION
   # der er en lille fejl i ODBC udvidelsen som skal fixes
   # Se https://www.mediawiki.org/wiki/Extension:OdbcDatabase#Possible_code_changes
   $SED -i'' "s/public static function getSoftwareLink/public function getSoftwareLink/" \
	/var/www/wiki/extensions/OdbcDatabase/OdbcDatabase.body.php

   # Install Maintenance
   cd /var/www/wiki/extensions/
   git clone https://github.com/wikimedia/mediawiki-extensions-Maintenance.git
   mv mediawiki-extensions-Maintenance Maintenance
   cd /var/www/wiki/extensions/Maintenance
   git checkout -q REL1_$SEMAWI_MW_MINOR_VERSION

   # Install PlantUML
   cd /var/www/wiki/extensions/
   git clone https://github.com/pjkersten/PlantUML.git
   curl -L https://downloads.sourceforge.net/project/plantuml/plantuml.jar -o /usr/local/plantuml.jar

   # We'll need a Sysop/Beaureaucrat
   echo "Creating the default user SeMaWi..."
   php /var/www/wiki/maintenance/createAndPromote.php --force --bureaucrat \
       --sysop SeMaWi SeMaWiSeMaWi

   # We'll need a bot for the GC2 sync
   echo "Creating bot account for Geocloud2 sync..."
   php /var/www/wiki/maintenance/createAndPromote.php --force --bureaucrat \
       --sysop --bot Sitebot SitebotSitebot

fi

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2.pid

exec apache2 -DFOREGROUND
