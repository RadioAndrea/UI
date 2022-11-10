FROM ubuntu:20.04

LABEL maintainer="FreeTAKTeam"

ARG FTS_UI_VERSION=1.9.9.1

# UTC for buildtimes
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime

#APT
RUN apt-get update && \
    apt-get install -y libssl-dev libffi-dev curl python3 python3-pip \
            libxml2-dev libxslt-dev python3-lxml python3-dev \
            python3-setuptools build-essential iproute2 &&\
    rm -rf /var/lib/apt/lists/*


#PIP3
RUN pip3 install supervisor &&\
    pip3 install requests &&\
    pip3 install flask_login &&\
    pip3 install FreeTAKServer-UI==${FTS_UI_VERSION} && \
    pip3 install pyopenssl &&\
    pip3 install pytak

# Create FTS user
RUN addgroup --gid 1000 fts && \
    adduser --disabled-password --uid 1000 --ingroup fts --home /home/fts fts

# Supervisord conf
COPY support/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# Logrotation
COPY support/ftsrotate /etc/logrotate.d/ftsrotate

COPY support/fatalexit /usr/local/bin/fatalexit
RUN  chmod +x /usr/local/bin/fatalexit


# Start script
# This handles env variables and starts the service
COPY support/start-fts.sh /start-fts.sh
RUN chmod +x /start-fts.sh

# FTS UI port
EXPOSE 5000

# UI Config changes
RUN sed -i 's/root/data/g' /usr/local/lib/python3.8/dist-packages/FreeTAKServer-UI/config.py &&\
    sed -i 's+certpath = .*+certpath = "/data/certs/"+g' /usr/local/lib/python3.8/dist-packages/FreeTAKServer-UI/config.py  &&\
    #Adjust database path
    sed -i 's/data\/FTSDataBase.db/data\/database\/FTSDataBase.db/g' /usr/local/lib/python3.8/dist-packages/FreeTAKServer-UI/config.py &&\
    chmod 777 /usr/local/lib/python3.8/dist-packages/FreeTAKServer-UI/config.py &&\
    chmod 777 /usr/local/lib/python3.8/dist-packages/FreeTAKServer-UI/


ENV APPIP=0.0.0.0

# Use non root user
# TODO: Folder perms
USER fts

ENTRYPOINT ["/bin/bash", "/start-fts.sh"]