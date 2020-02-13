#!make
include .env

build:
	docker-compose build

up: build
	docker-compose up -d

down:
	docker-compose down

clean:
	docker-compose down -v
	yes | docker image prune

distclean: clean
	docker rmi semawi:${SEMAWI_VERSION}

ps:
	docker-compose ps

mw_runjobs:
	docker exec semawi-mediawiki /usr/bin/php /var/www/wiki/maintenance/runJobs.php

mw_update:
	docker exec semawi-mediawiki /usr/bin/php /var/www/wiki/maintenance/update.php

mw_enter:
	docker exec -ti semawi-mediawiki /bin/bash

loaddata:
	docker exec semawi-mediawiki /bin/bash /usr/local/bin/loaddata.sh
