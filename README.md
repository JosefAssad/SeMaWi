# About this software

SeMaWi is a Semantic Mediawiki distribution which ships with a pre-made data
model for Danish municipalities.

# Deploying SeMaWi

SeMaWi requires the following:

1. A Linux host (ideally, Debian)
2. Docker
3. Docker Compose
4. SSL/TLS certificates

## Preparing the SSL/TLS certificates

### Production (letsencrypt)

The docker host requires `certbot` installed. In the recommended Debian Buster
docker host environment, the command is `sudo apt install certbot`.

Then we must generate standalone certificates:

```bash
	sudo certbot certonly --standalone -d semawi.notanumber.dk \
		--non-interactive --agree-tos -m test@example.com \
		--cert-name semawi
```

If this runs successfully, the last step is to link to the files:

```bash
	sudo ln -s /etc/letsencrypt/live/semawi/privkey.pem .
	sudo ln -s /etc/letsencrypt/live/semawi/cert.pem .
```

### Development (self-signed)

For development purposes, the provided Makefile has a target `certs` which will
create the required self-signed certificate files in the correct location.

## Deployment

It ships with a `Makefile` which has some convenient targets. To deploy SeMaWi:

1. Git clone the source code from https://github.com/ballerupgis/SeMaWi.
2. Ensure you have docker and docker-compose available
3. Copy the file `env-sample` to `.env` and edit it to suit your needs.
4. Issue `make up && docker logs -f semawi-mediawiki`
5. When the server has booted, open a browser to your configured location. When
   it displays an error about upgrade keys, proceed to the next step.
6. Issue `make loaddata` and go for some coffee.
7. The server will exhaust memory a few times in this last step. Each time it
   does, issue a `make runjobs`.
8. When there's no more jobs on the queue, SeMaWi is ready.

# Modifying a deployed SeMaWi

The `.env` file has some run-time values which can be modified. They are in the
run-time configuration section. If you want to adapt any of these and preserve a
running SeMaWi instance:

1. Edit the runtime variable in `.env`
2. Issue `make reload`
3. Issue `make update`

# Upgrading from a previous SeMaWi version

The First Rule of Upgrade Club is, do NOT kill your old instance before you are
sure the new one works fine.

The process for moving from an older version is roughly:

1. Take backup of data and settings
2. Move them into an instance of the new version
3. Kick the new version

## 2018.1 to 2020.1

In more detail:

1. Take a db dump from the old SeMaWi: `docker exec semawi-mysql mysqldump -u
   wiki --password=wiki wiki > db.sql`.
2. Copy over the images folder with `docker cp
   semawi-mediawiki:/var/www/wiki/images/ .`.
3. Back up configuration settings from the `/srv/semawi` folder. Specifically
   you will want the ODBC configuration, GC2 configuration, `LocalSettings.php`,
   etc. This location for mutable data along with the GC2 and ODBC is deprecated
   from release 2020.1 but you will want a record of those files.
4. Fetch the latest SeMaWi sources and cd into the folder.
5. You need a python venv with `docker-compose`. Execute `python3 -m venv .venv`
   then `source .venv/bin/activate` then `pip install --upggrade pip` then `pip
   install docker-compose`.
6. Copy `env-sample` to `.env` and edit it to suit the instance configuration.
7. Execute `make up && docker logs -f semawi-mediawiki`.
8. Wait for the server to come up.
9. Copy the database dump to the MySQL container: `docker cp db.sql
   semawi-mysql:/tmp/`.
10. Load the database dump: `docker exec -i semawi-mysql /bin/bash -c 'mysql -u
    wiki --password=wiki wiki < /tmp/db.sql'`.
11. Copy the images over to a temp location on the MediaWiki container: `docker
    cp images semawi-mediawiki:/tmp/`.
12. Jump into the MediaWiki container: `docker exec -ti semawi-mediawiki
    /bin/bash`.
13. Go to the `images` directory: `cd /var/www/wiki/images/` and copy over
    everything from the backup: `cp -av /tmp/images/* .`.
14. Reassert the correct ownership on files: `chown -R www-data:www-data ./*`.
15. Execute the MediaWiki update script: `php
    /var/www/wiki/maintenance/update.php`.
16. Execute the MediaWiki job runner script: `php
    /var/www/wiki/maintenance/runJobs.php`.
17. Go ahead and remove the temporary images copy: `docker exec semawi-mediawiki
    rm -rf /tmp/images/`.
