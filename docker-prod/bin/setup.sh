#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."

# Warten, bis der EspoCRM-Container die Installation/Initialisierung abgeschlossen hat.
echo "Warte auf EspoCRM-Initialisierung (max. 180s)..."
for i in $(seq 1 36); do
  if docker exec mc_expocrm test -f /var/www/html/command.php 2>/dev/null; then
    break
  fi
  sleep 5
done

# Berechtigungen der versionierten Bind-Mounts auf den Webserver-User setzen.
docker exec mc_expocrm chown -R www-data:www-data \
  /var/www/html/custom/Espo/Custom \
  /var/www/html/client/custom 2>/dev/null || true

echo "Setup fertig."
echo "Admin-Login: ${ESPOCRM_SITE_URL:-siehe .env}  (User/Passwort aus .env)"
