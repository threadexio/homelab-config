FROM docker.io/alpine

RUN apk add --no-cache vsftpd

RUN mkdir -p /ftp

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh

STOPSIGNAL SIGKILL
ENTRYPOINT ["/entrypoint.sh"]
