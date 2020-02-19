# About this software

SeMaWi is a Semantic Mediawiki distribution which ships with a pre-made data
model for Danish municipalities.

# Deploying SeMaWi

SeMaWi requires the following:

1. A Linux host (ideally, Debian)
2. Docker
3. Docker Compose

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
