FROM mysql:5.7

COPY my.cnf /etc/mysql/my.cnf

HEALTHCHECK --interval=30s --timeout=10s --start-period=1m --retries=3 \
	CMD mysqladmin -h 127.0.0.1 -u $MYSQL_USER -p$MYSQL_PASSWORD ping
