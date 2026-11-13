#!/usr/bin/env bash
# Stops and removes the supervisor programs from this repo.
# Usage: sudo ./scripts/uninstall.sh [--purge-supervisor]
set -euo pipefail
CONF_DIR=/etc/supervisor/conf.d
FILES=(nginx.conf gunicorn.conf react.conf gunicorn-wsgi.conf gunicorn-asgi.conf)

[[ $EUID -eq 0 ]] || { echo "Run with sudo."; exit 1; }
echo "Will stop all three programs and delete any of these from $CONF_DIR:"
printf '  %s\n' "${FILES[@]}"
read -r -p "Continue? [y/N] " a; [[ $a == [yY] ]] || exit 0

supervisorctl stop 'nginx:*' 'gunicorn:*' react_app || true
for f in "${FILES[@]}"; do rm -f "$CONF_DIR/$f"; done
supervisorctl reread
supervisorctl update

if [[ ${1:-} == --purge-supervisor ]]; then
  echo "This removes supervisor for EVERY project on this machine."
  read -r -p "Type 'purge' to confirm: " c; [[ $c == purge ]] || exit 0
  systemctl stop supervisor && systemctl disable supervisor
  apt-get purge -y supervisor && apt-get autoremove -y
  rm -rf /etc/supervisor /var/log/supervisor
fi
echo "Done. Logs, sockets, nginx and your code were left untouched (see docs for those steps)."
