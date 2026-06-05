.PHONY: up update down logs ps

# Erststart / Bringt den Stack hoch und richtet Berechtigungen ein
up:
	docker compose pull
	docker compose up -d
	bin/setup.sh

# Nach 'git pull': Images aktualisieren, Espo-Rebuild der versionierten Anpassungen
update:
	docker compose pull
	docker compose up -d
	bin/update.sh

down:
	docker compose down

logs:
	docker compose logs -f --tail=100

ps:
	docker compose ps
