.PHONY: up down logs ps rebuild

# Lokalen Stack starten — danach: http://localhost:8080
up:
	docker compose pull
	docker compose up -d

down:
	docker compose down

# Achtung: löscht auch lokale Daten (Volumes)
reset:
	docker compose down -v

logs:
	docker compose logs -f --tail=100

ps:
	docker compose ps

# Espo-Metadaten neu aufbauen (nach Änderungen an app/custom)
rebuild:
	docker exec -u www-data mc_expocrm_dev php command.php rebuild
