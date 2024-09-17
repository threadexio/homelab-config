FROM docker.io/alpine:edge

RUN apk --no-cache add samba

EXPOSE 135 445

ENV USERS_FILE /users

COPY entry.sh /entry.sh
ENTRYPOINT [ "/bin/sh", "/entry.sh" ]
