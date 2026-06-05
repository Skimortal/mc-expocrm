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

# Berechtigungen der versionierten Bind-Mounts setzen.
# Doppelte Schreiber: Container (www-data, uid 33) bei UI-Anpassungen UND
# User aleks (Mitglied der Gruppe www-data/gid 33) bei 'git pull'.
# Lösung: Eigentümer www-data:www-data, Verzeichnisse setgid + group-write (2775),
# Dateien group-write (0664). So können beide schreiben.
docker exec mc_expocrm sh -c '
  set -e
  for d in /var/www/html/custom/Espo/Custom /var/www/html/client/custom; do
    chown -R www-data:www-data "$d"
    find "$d" -type d -exec chmod 2775 {} +
    find "$d" -type f -exec chmod 0664 {} +
  done
' 2>/dev/null || true

echo "Setup fertig."
echo "Admin-Login: ${ESPOCRM_SITE_URL:-siehe .env}  (User/Passwort aus .env)"
