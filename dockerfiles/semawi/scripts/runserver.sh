#!/bin/bash

set -e

# wait for mysql container to be ready
echo "Waiting for db to come online..."
until mysqladmin -h semawi-mysql -u wiki -pwiki ping &>/dev/null; do
    echo -n "."; sleep 0.2
done
echo "DB is online!"

if [[ $(mysql -N -s -h semawi-mysql -u wiki -pwiki wiki -e "select count(*) from information_schema.tables where table_schema='wiki' and table_name='recentchanges';") -eq 1 ]]; then
    echo "database already installed"
else
    # perform the installation
    echo "installing"
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

    # We'll need a Sysop/Beaureaucrat
    echo "Creating the default user SeMaWi..."
    php /var/www/wiki/maintenance/createAndPromote.php --force --bureaucrat \
	--sysop SeMaWi SeMaWiSeMaWi
fi

# copy over our desired LocalSettings file
cp /tmp/LocalSettings.php /var/www/wiki/LocalSettings.php

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2.pid

# choose which apache conf to activate depending on if we want basic auth or not
if [ "$SEMAWI_USE_HTPASS" = "YES" ]; then
	a2ensite 001-semawi-htpass
else
	a2ensite 001-semawi
fi

exec apache2 -DFOREGROUND
