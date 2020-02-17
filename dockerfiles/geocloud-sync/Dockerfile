ARG PYTHON_VERSION=3.7
FROM python:$PYTHON_VERSION

RUN pip install gunicorn
RUN useradd -ms /bin/bash gc2sync

WORKDIR /home/gc2sync
USER gc2sync

COPY requirements.txt requirements.txt

COPY gc2sync gc2sync
COPY run.sh run.sh

RUN pip install --user -r requirements.txt
RUN pip install --user ./gc2sync

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=1m --retries=3 \
	CMD curl 127.0.0.1:5000/healthz

ENTRYPOINT ["./run.sh"]
