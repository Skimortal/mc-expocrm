#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."

# Nach 'git pull': Berechtigungen richten und Espo-Metadaten neu aufbauen,
# damit geänderte Anpassungen aus app/custom + app/client/custom greifen.
docker exec mc_expocrm chown -R www-data:www-data \
  /var/www/html/custom/Espo/Custom \
  /var/www/html/client/custom 2>/dev/null || true

# Rebuild (baut Metadaten neu auf und leert den Cache).
docker exec -u www-data mc_expocrm php command.php rebuild

echo "Update fertig (rebuild + cache clear)."
