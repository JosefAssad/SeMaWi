#!make
include .env

up:
	docker-compose up -d

down:
	docker-compose down

clean:
	docker-compose down -v

distclean: clean
	docker rmi semawi:${SEMAWI_VERSION}

ps:
	docker-compose ps
