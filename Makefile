#!make
include .env

build:
	docker-compose build

up: build certs
	docker-compose up -d

down:
	docker-compose down

clean:
	docker-compose down -v
	yes | docker image prune
	rm cert.pem privkey.pem

distclean: clean
	docker rmi semawi/mediawiki:${SEMAWI_VERSION}
	docker rmi semawi/cron:${SEMAWI_VERSION}
	docker rmi semawi/mysql:${SEMAWI_VERSION}

ps:
	docker-compose ps

mw_runjobs:
	docker exec semawi-mediawiki /usr/bin/php /var/www/wiki/maintenance/runJobs.php

mw_update:
	docker exec semawi-mediawiki /usr/bin/php /var/www/wiki/maintenance/update.php --quick

mw_enter:
	docker exec -ti semawi-mediawiki /bin/bash

loaddata:
	docker exec semawi-mediawiki /bin/bash /usr/local/bin/loaddata.sh

logs:
	docker-compose logs -f

reload:
	docker-compose up -d --force-recreate semawi

certs:
ifeq ($(SEMAWI_DEPLOYMENT_ENVIRONMENT),prod)
	sudo certbot certonly --standalone -d ${SEMAWI_WGSERVER} --non-interactive \
	--agree-tos -m ${SEMAWI_ADMIN} --cert-name semawi
	sudo cp /etc/letsencrypt/live/semawi/privkey.pem .
	sudo cp /etc/letsencrypt/live/semawi/fullchain.pem .
	sudo sh -c 'chmod $SUDO_UID:$SUDO_GID privkey.pem'
	sudo sh -c 'chmod $SUDO_UID:$SUDO_GID fullchain.pem'
else
	openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
		-keyout privkey.pem \
		-out cert.pem \
		-subj /CN=${SEMAWI_WGSERVER} \
		-addext subjectAltName=DNS:${SEMAWI_WGSERVER}

endif
