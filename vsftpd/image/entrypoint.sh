#!/usr/bin/env sh
set -eu -o pipefail

UID="${UID:?expected \$UID}"
GID="${GID:?expected \$GID}"
USERS_FILE="${USERS_FILE:?expected \$USERS_FILE}"

addgroup -g "$GID" vsftpd
adduser -D -s /sbin/nologin -H -h /data -u "$UID" -G vsftpd vsftpd

while IFS=: read -r user uid pw; do
  adduser -D -H -h /data -u "$uid" -G vsftpd "$user"
  echo "$user:$pw" | chpasswd -e 2>/dev/null
done < "$USERS_FILE"

exec /usr/sbin/vsftpd \
  -onopriv_user=vsftpd \
  -oseccomp_sandbox=NO \
  -obackground=NO \
  /etc/vsftpd/vsftpd.conf
