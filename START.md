# Startanleitung

1. Im internen DNS zwei A-Records auf die IP des Ubuntu-Servers setzen:

   - `cloud.home.arpa`
   - `office.home.arpa`

2. Stack starten:

   ```bash
   docker compose config
   docker compose pull
   docker compose up -d
   docker compose ps
   ```

3. Caddy-Root-Zertifikat exportieren:

   ```bash
   docker cp nextcloud-caddy:/data/caddy/pki/authorities/local/root.crt ./caddy-root-ca.crt
   ```

4. Auf dem Ubuntu-Arbeitsplatz installieren:

   ```bash
   ./install-caddy-ca-ubuntu.sh ./caddy-root-ca.crt
   ```

5. Nextcloud öffnen:

   `https://cloud.home.arpa`

6. In Nextcloud unter Administrationseinstellungen -> Office eintragen:

   `https://office.home.arpa`

Wichtig: Das Volume `caddy_data` sichern und nicht löschen. Es enthält die interne Zertifizierungsstelle.
