# Nextcloud AIO

Nextcloud All-in-One behind `caddy-docker-proxy`. AIO's apache container joins the
shared `caddy` network so Caddy reaches it container-to-container — no public host
port — and the admin/setup UI is kept on a private (e.g. Tailscale) address.

## Env Vars

- `NEXTCLOUD_DOMAIN` - Public domain Caddy serves Nextcloud on (used by the caddy label).
- `CADDY_INGRESS_NETWORK` - Shared Caddy ingress network (default `caddy`).
- `AIO_ADMIN_PORT` / `AIO_ADMIN_BIND` - Host port + bind address for the AIO admin UI.
  Bind to a private/Tailscale IP — do **not** expose it publicly.
- `NEXTCLOUD_APACHE_PORT` - Port AIO's apache listens on; Caddy proxies to
  `nextcloud-aio-apache:<this>`.
- `NEXTCLOUD_APACHE_IP_BINDING` - Keep `127.0.0.1` (host publish stays local; real
  ingress is via the caddy network).
- `NEXTCLOUD_DATADIR` - Host path for Nextcloud `ncdata` (long-term user file data).
- `NEXTCLOUD_STARTUP_APPS` / `NEXTCLOUD_UPLOAD_LIMIT` / `NEXTCLOUD_MAX_TIME` /
  `NEXTCLOUD_MEMORY_LIMIT` - app + PHP/runtime tuning.
- `SKIP_DOMAIN_VALIDATION` - keep `true` behind Cloudflare + Caddy.

## How to Run

```bash
cp .env.example .env   # edit values
docker compose -f stack.yml --env-file .env up -d
```

Then open the AIO admin UI at `https://<private-ip>:${AIO_ADMIN_PORT}` (e.g. a Tailscale
IP), save the generated passphrase, set the Nextcloud domain to your `${NEXTCLOUD_DOMAIN}`
(e.g. `cloud.example.com`), and start the containers.

## Reverse proxy (caddy-docker-proxy)

AIO's apache joins `caddy` via `APACHE_ADDITIONAL_NETWORK`, so the public site proxies
to the apache service by name — no host IP, no published apache port:

```yaml
labels:
  caddy: ${NEXTCLOUD_DOMAIN}
  caddy.reverse_proxy: "nextcloud-aio-apache:${NEXTCLOUD_APACHE_PORT}"
```

## ncdata

Nextcloud user files live on a dedicated host path (`NEXTCLOUD_DATADIR`, e.g.
`/mnt/nextcloud/data`). That makes the data easy to back up (restic/rclone, etc.) and
migrate later. Treat it as a first-install decision and do not change it afterward.

## Authentik

OIDC SSO is configured **inside** Nextcloud after it's running (not part of this compose).
