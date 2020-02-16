FROM python:3.7

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

ENTRYPOINT ["./run.sh"]
