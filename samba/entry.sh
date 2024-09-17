#!/bin/sh
set -eu -o pipefail

cat "${USERS_FILE}" | awk -F ':' $'
BEGIN { print "set -eu" }
{
    user=$1
    uid=$2
    passwd=$3

    q="\047"
    print "adduser -DHS -s /sbin/nologin -u", q uid q, "-h /shares --", q user q
    print "echo -e", q passwd "\\\\n" passwd q, "| smbpasswd -a", q user q, ">/dev/null"
}' | sh

testparm
exec /usr/sbin/smbd --foreground --debug-stdout --no-process-group
