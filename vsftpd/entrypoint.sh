#!/usr/bin/env sh
set -eu

UID="${UID:-1000}"
USERS_FILE="${USERS_FILE:-/run/secrets/ftpusers}"

cp /vsftpd.conf /etc/vsftpd.conf
adduser -D -s /sbin/nologin -H -h /ftp -u "$UID" -g "FTP user" ftpuser

while IFS=: read -r uid user pw; do
  adduser -D -H -h /ftp -u "$uid" "$user"
  echo "$user:$pw" | chpasswd -e 2>/dev/null
done < "$USERS_FILE"

exec /usr/sbin/vsftpd \
  -onopriv_user=ftpuser \
  -oseccomp_sandbox=NO \
  -obackground=NO \
  /etc/vsftpd.conf
