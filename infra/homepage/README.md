# Homepage — the central dashboard

[gethomepage.dev](https://gethomepage.dev) hub linking every service, at
`${HOMEPAGE_DOMAIN}` behind **Authentik forward auth** (caddy-docker-proxy labels).

## Services
- **homepage** — the dashboard. Config is mounted from `./config`
  (`settings.yaml`, `services.yaml`, `widgets.yaml`, `bookmarks.yaml`; Homepage
  also drops empty `docker.yaml`/`kubernetes.yaml`/`proxmox.yaml` defaults). Needs
  `HOMEPAGE_ALLOWED_HOSTS=${HOMEPAGE_DOMAIN}`.
- **homepage-status** — a tiny nginx serving the restic **backup status JSON**
  (`deployments/backup-status.json`, written by `deployments/bin/backup.sh`) so the
  dashboard's `customapi` widget can poll it server-side at
  `http://homepage-status/backup-status.json`. The file must be world-readable (the
  status writer chmods it `644`).

## Backup tile
The "Backups" group uses a `customapi` widget mapping the JSON's per-app `status`
(plus `running.app` for an in-progress indicator). Apps appear once they've been
backed up at least once.

## Adding service widgets (with API keys)
Link tiles need no secrets. For richer widgets (e.g. Nextcloud usage), add the
widget block in `services.yaml` and pass the API key via an env var
`HOMEPAGE_VAR_*` resolved from 1Password (`op://`) in the deploy env — never inline.
