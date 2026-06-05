# MOST Connect CRM (EspoCRM)

Self-hosted [EspoCRM](https://www.espocrm.com/) für die MOST Connect KG.
Läuft produktiv unter **https://crm.most-connect.com** auf dem Server `quigon`.

CRM aus dem Tool-/IT-Konzept (Kap. 3): Kontakte (Hersteller/Einkäufer), Firmen,
Deals/Ausschreibungen als Pipeline, Aufgaben/Kanban.

## Architektur

- **espocrm** – Anwendung (Apache/PHP, offizielles Image `espocrm/espocrm`)
- **daemon** – Hintergrund-Jobs (Cron, Workflows, E-Mail-Abruf)
- **db** – MySQL 8.0

Produktiv läuft alles am externen Docker-Netz `webnet` hinter dem zentralen
`nginx_proxy` (Ports 80/443). TLS über das vorhandene Wildcard-Zertifikat
`*.most-connect.com`.

### Was liegt in Git, was in Volumes?

- **Git (dieses Repo):** Infrastruktur (Compose, Env-Templates, Proxy-Conf) **und**
  die versionierten EspoCRM-Anpassungen unter `app/custom/Espo/Custom` +
  `app/client/custom` (Layouts, Entitäten, Felder als JSON-Metadaten).
- **Docker-Volumes (nicht in Git):** Produkt-Code, hochgeladene Dateien, Espo-Config
  und alle Datensätze. Die Datenbank wird nächtlich automatisch nach `/srv/_backups`
  gesichert (server-seitiges Backup-Script, erkennt MySQL-Container selbst).

> Layout-/Feld-Änderungen im Admin-UI schreiben JSON nach `app/custom/...` →
> `git commit` + `push` → am Server `git pull` + `make update`.

## Lokal entwickeln

```bash
cd docker-dev
cp .env.tmp .env          # Werte für lokal sind ok wie sie sind
make up                   # Stack starten
# -> http://localhost:8080  (Login: admin / admin123)
```

Nach Änderungen an `app/custom`: `make rebuild`.
Stoppen: `make down` · Alles inkl. lokaler Daten löschen: `make reset`.

## Produktiv-Deployment (Server quigon)

Verzeichnis: `/srv/most-connect.com/mc-expocrm`

### Erstinstallation

```bash
git clone git@github.com:Skimortal/mc-expocrm.git /srv/most-connect.com/mc-expocrm
cd /srv/most-connect.com/mc-expocrm/docker-prod
cp .env.tmp .env
# .env: Secrets eintragen — z.B. via:  openssl rand -hex 24
make up

# Reverse-Proxy einrichten:
cp ../proxy/crm.most-connect.conf /proxy/nginx/conf.d/crm.most-connect.conf
docker exec nginx_proxy nginx -t && docker exec nginx_proxy nginx -s reload
```

DNS-Voraussetzung: `crm.most-connect.com  A  65.21.123.123`.

### Updates einspielen

```bash
cd /srv/most-connect.com/mc-expocrm
git pull
cd docker-prod
make update      # zieht neue Images, baut Espo-Metadaten neu auf
```

## Wiederherstellung (Recovery)

1. Repo neu clonen, `docker-prod/.env` aus dem Passwort-Manager wiederherstellen.
2. `make up` → leerer EspoCRM-Stack startet.
3. Letzten DB-Dump aus `/srv/_backups/mc_expocrm_db/<datum>/` in den DB-Container einspielen.
4. `make update` (rebuild).

## Hinweise

- **E-Mail-Anbindung** (IMAP/SMTP) wird im EspoCRM-Admin konfiguriert (nicht Teil dieses Repos).
- **Echtzeit-Benachrichtigungen** (WebSocket) sind bewusst deaktiviert; bei Bedarf
  zusätzlichen `mc_expocrm_ws`-Container + wss-Proxy-Route nachrüsten.
