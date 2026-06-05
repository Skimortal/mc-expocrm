#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."

# Nach 'git pull': Berechtigungen wiederherstellen (git-checkout setzt 0644 zurück),
# damit der Container (www-data) die versionierten Anpassungen weiter schreiben kann.
docker exec mc_expocrm sh -c '
  set -e
  for d in /var/www/html/custom/Espo/Custom /var/www/html/client/custom; do
    chown -R www-data:www-data "$d"
    find "$d" -type d -exec chmod 2775 {} +
    find "$d" -type f -exec chmod 0664 {} +
  done
' 2>/dev/null || true

# Espo-Metadaten neu aufbauen (baut Metadaten neu auf und leert den Cache).
docker exec -u www-data mc_expocrm php command.php rebuild

echo "Update fertig (rebuild + cache clear)."
