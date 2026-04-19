# Nextcloud AIO

Minimal Nextcloud AIO stack for host-IP reverse proxying with Caddy.

## Env Vars

- `AIO_ADMIN_PORT` - Host port for the AIO admin UI.
- `NEXTCLOUD_APACHE_PORT` - Host port Caddy proxies to for normal Nextcloud traffic.
- `NEXTCLOUD_APACHE_IP_BINDING` - Host IP the AIO-managed Apache container binds to.
- `NEXTCLOUD_DATADIR` - Host path for Nextcloud `ncdata`. This is the long-term location for user file data.
- `NEXTCLOUD_STARTUP_APPS` - Apps enabled during initial setup.
- `NEXTCLOUD_UPLOAD_LIMIT` - Upload size limit.
- `NEXTCLOUD_MAX_TIME` - PHP max execution time.
- `NEXTCLOUD_MEMORY_LIMIT` - PHP memory limit.
- `SKIP_DOMAIN_VALIDATION` - Usually keep `false`.

## How to Run

```bash
docker compose -f stack.yml --env-file .env.example up -d
```

Before first boot, make sure `NEXTCLOUD_DATADIR` exists on the host and keep that path stable after setup.
Open the AIO admin UI at `https://10.0.0.22:18080` and use the server IP, not the public domain.
During setup, set the Nextcloud domain to `cloud.usmanasad.ca`.

## Caddy

```caddy
cloud.usmanasad.ca {
    reverse_proxy http://10.0.0.22:21100
}
```

This stack intentionally does not use `APACHE_ADDITIONAL_NETWORK`, external Docker networks, or service-name proxying.
Caddy should connect to the host IP and Apache port directly.

## ncdata

The `ncdata` approach stores Nextcloud user files on a dedicated host path:

- `/mnt/nextcloud/data`

That makes the data location easier to understand, back up with tools like Kopia, and migrate later.
Treat it as a first-install decision and do not change it after Nextcloud is initialized.

## Authentik

Authentik is not part of this compose.
After Nextcloud is running, configure Authentik OIDC inside Nextcloud.
