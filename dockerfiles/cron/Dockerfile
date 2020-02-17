# -*- mode: Dockerfile;-*-

FROM alpine:3.11
# copy crontabs for root user
COPY semawi.cron /etc/crontabs/root
RUN apk add curl
HEALTHCHECK --interval=5s --timeout=3s \
	CMD ps aux | grep '[c]rond' || exit 1
# start crond with log level 8 in foreground, output to stderr
CMD ["crond", "-f", "-d", "8"]
