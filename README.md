# docker-nextcloud

Docker-basierter Nextcloud-Stack für kleine bis mittelgroße Umgebungen.

## Enthaltene Dienste

| Dienst | Beschreibung |
|--------|--------------|
| Nextcloud | Dateien, Ordner, Kalender und Kontakte |
| MariaDB | Datenbank |
| Redis | Cache und Transactional File Locking |
| Cron | Hintergrundaufgaben für Nextcloud |
| Collabora CODE | Online Office für Word, Excel und PowerPoint |

---

## Voraussetzungen

- Docker Engine 24+
- Docker Compose v2
- Linux, empfohlen: Ubuntu Server 24.04 LTS

## Empfohlene Hardware

| Komponente | Empfehlung |
|------------|------------|
| CPU | mindestens 4 Kerne |
| RAM | mindestens 8 GB |
| Speicher | SSD empfohlen |

---

## Installation

### Repository klonen

```bash
git clone <repository-url>
cd docker-nextcloud
```

### Konfiguration vorbereiten

Die `.env` aus der Beispieldatei erstellen:

```bash
cp .env.example .env
```

Danach alle Passwörter, Ports und Server-Adressen in der `.env` anpassen.

---

## Container starten

Images herunterladen:

```bash
docker compose pull
```

Container starten:

```bash
docker compose up -d
```

Status prüfen:

```bash
docker compose ps
```

---

## Logs anzeigen

Alle Dienste:

```bash
docker compose logs -f
```

Nur Nextcloud:

```bash
docker compose logs -f app
```

Nur Datenbank:

```bash
docker compose logs -f db
```

Nur Collabora:

```bash
docker compose logs -f collabora
```

---

## Erstinstallation

Nach dem Start die Nextcloud-Weboberfläche öffnen:

```text
http://SERVER-IP:NEXTCLOUD_PORT
```

Beispiel:

```text
http://192.168.176.61:8090
```

Anschließend:

1. Administrator erstellen
2. Installation abschließen
3. Anmeldung durchführen

Danach im **App Store** installieren:

- Nextcloud Office
- Talk

---

## Zugriff und Office-Anbindung

Nach dem Start des Stacks kann Nextcloud über folgende Adresse geöffnet werden:

```text
http://192.168.176.61:8090
```

### Collabora / Nextcloud Office einrichten

Damit Word-, Excel- und PowerPoint-Dateien im Browser bearbeitet werden können, muss Collabora in Nextcloud eingetragen werden.

In Nextcloud öffnen:

```text
Administrationseinstellungen -> Office
```

Dort als Collabora-Server eintragen:

```text
http://192.168.176.61:9980
```

Nicht eintragen:

```text
http://collabora:9980
```

Der interne Docker-Name `collabora` ist nur innerhalb des Docker-Netzwerks erreichbar. Der Browser des Benutzers muss den Collabora-Server ebenfalls erreichen können. Deshalb muss hier die echte Server-Adresse verwendet werden.

---

## Backup

Folgende Daten sollten regelmäßig gesichert werden:

- Datenbank
- Nextcloud-Konfiguration
- Benutzerdaten
- Eigene Apps

### Relevante Volumes

```text
db_data
nextcloud_data
nextcloud_config
nextcloud_apps
nextcloud_html
```

---

## Wiederherstellung

Für eine vollständige Wiederherstellung werden benötigt:

- Datenbank-Backup
- alle Docker Volumes
- `.env`
- `docker-compose.yml`

---

## Portbelegung

| Dienst | Interner Port | Externer Port | Beschreibung |
|--------|--------------:|--------------:|--------------|
| Nextcloud | 80 | 8090 | Weboberfläche |
| Collabora CODE | 9980 | 9980 | Office |
| MariaDB | 3306 | – | nur internes Docker-Netzwerk |
| Redis | 6379 | – | nur internes Docker-Netzwerk |

> **Hinweis:** MariaDB und Redis sollten niemals direkt aus dem Internet erreichbar sein.

---

## Projektstruktur

```text
.
├── docker-compose.yml
├── .env
├── .env.example
├── README.md
└── backups/
```

---

## Beispiel `.env`

```env
#########################################
# Nextcloud
#########################################

NEXTCLOUD_VERSION=33-apache
NEXTCLOUD_PORT=8090

NEXTCLOUD_DOMAIN=192.168.176.61:8090
NEXTCLOUD_TRUSTED_DOMAINS=192.168.176.61 192.168.176.61:8090 localhost

OVERWRITEPROTOCOL=http
OVERWRITEHOST=192.168.176.61:8090
OVERWRITECLIURL=http://192.168.176.61:8090

#########################################
# MariaDB
#########################################

MYSQL_ROOT_PASSWORD=CHANGE_ME_ROOT_PASSWORD
MYSQL_DATABASE=nextcloud
MYSQL_USER=nextcloud
MYSQL_PASSWORD=CHANGE_ME_DB_PASSWORD

#########################################
# Redis
#########################################

REDIS_PASSWORD=CHANGE_ME_REDIS_PASSWORD

#########################################
# Collabora CODE
#########################################

COLLABORA_PORT=9980

# Erlaubt Nextcloud unter http://192.168.176.61:8090
# Wichtig: Punkte müssen escaped werden.
COLLABORA_ALLOWED_DOMAIN=192\\.168\\.176\\.61:8090

COLLABORA_ADMIN_USER=admin
COLLABORA_ADMIN_PASSWORD=CHANGE_ME_OFFICE_PASSWORD

# Shared Memory für Collabora
COLLABORA_SHM_SIZE=1gb
```

---

## Container verwalten

Stack stoppen:

```bash
docker compose down
```

Stack starten:

```bash
docker compose up -d
```

Container neu starten:

```bash
docker compose restart
```

Images aktualisieren:

```bash
docker compose pull
docker compose up -d
```

Stack vollständig löschen, inklusive Volumes:

```bash
docker compose down -v
```

> **Achtung:** `docker compose down -v` löscht auch Datenbank- und Nextcloud-Daten. Nur ausführen, wenn ein Backup vorhanden ist oder die Installation verworfen werden soll.

---

## Produktivbetrieb

Für einen sicheren Betrieb werden folgende Maßnahmen empfohlen:

- Reverse Proxy, z. B. Traefik oder Nginx Proxy Manager
- HTTPS mit Let's Encrypt
- regelmäßige Backups
- getestete Wiederherstellung
- starke Passwörter
- feste Image-Versionen statt `latest`
- Monitoring, z. B. Uptime Kuma
- Log-Management
- Updates zuerst in einer Testumgebung prüfen
- Updates geplant einspielen

---

## Hinweise zu Collabora

Bei einer einfachen IP-/Port-Installation können im Collabora Server Audit Warnungen erscheinen, zum Beispiel:

- `Documents are not effectively contained`
- `Slow Kit jail setup with copying`
- `Poorly performing proxying of all network requests`

Für kleine Installationen ist das oft zunächst akzeptabel, solange Office-Dateien stabil geöffnet und gespeichert werden können.

Für eine produktivere Umgebung wird eine Reverse-Proxy-Struktur empfohlen:

```text
https://cloud.example.com  -> Nextcloud
https://office.example.com -> Collabora
```

---

## Lizenz

Dieses Projekt steht unter der MIT-Lizenz.

Eine Namensnennung ist nicht verpflichtend, wäre aber nett:

```text
Arthur Prymov
```