#!/usr/bin/env bash
set -eu -o pipefail
cd $( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

VAULTWARDEN_DATA=/lab/vaultwarden/data
BACKUP_KEY_FILE=/lab/vaultwarden/backup/key

die() {
  echo "error: $*"
  exit 1
}

do_backup() {
  tar -cvp -C "$VAULTWARDEN_DATA" -- .
}

do_restore() {
  tar -xvp -C "$VAULTWARDEN_DATA"
}

encrypt() {
  gzip -c | openssl enc -aes-256-cbc -pbkdf2 -pass "file:$BACKUP_KEY_FILE" -in - -out -
}

decrypt() {
  openssl enc -aes-256-cbc -pbkdf2 -pass "file:$BACKUP_KEY_FILE" -d -in - -out - | gzip -c -d
}

cmd_backup() {
  local is_default
  local file

  if [ -z "${1+x}" ]; then
    file="backup/$(date '+%F').enc"
    is_default=1
  else
    file="$1"
    is_default=0
  fi

  mkdir -p backup
  systemctl stop vaultwarden

  do_backup | encrypt > "$file"
  if [ "$is_default" -eq 1 ]; then
    ln -rsf "$file" backup/latest
  fi

  local dst="gdrive:/vaultwarden/$(basename "$file")"
  echo "copying to remote $dst..."
  rclone copyto "$file" "$dst"

  systemctl start vaultwarden
}

cmd_restore() {
  local file="${1:?missing backup file}"

  systemctl stop vaultwarden

  if [ -d "$VAULTWARDEN_DATA" ]; then
    die "destination has data"
  fi
  mkdir "$VAULTWARDEN_DATA"

  cat "$file" | decrypt | do_restore
}

main() {
  local cmd="${1:?missing command}"
  shift

  case "$cmd" in
    backup) cmd_backup "$@";;
    restore) cmd_restore "$@";;
    *) die "unknown command"
  esac
}

main "$@"

