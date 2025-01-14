#!/usr/bin/env bash
set -eu

SYSTEMD_CONTAINER_UNITS=/etc/containers/systemd

function link_unit {
  ln -vrsf "$1" "$SYSTEMD_CONTAINER_UNITS"
}

function main {
  cd units

  echo "linking unit files..."
  for f in *; do
    link_unit "$f"
  done

  echo "reloading systemd..."
  systemctl daemon-reload

  echo "ok"
}

main "$@"
