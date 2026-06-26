# Termix

Termix is a browser-based SSH/RDP/VNC workspace and connection manager
([upstream](https://github.com/LukeGus/Termix)). The optional `guacd` sidecar provides the
remote-desktop (RDP/VNC/Telnet) features; drop it if you only need SSH.

## Exposure: Tailscale-only

This stack is **private** — served behind a Caddy `@tailnet` gate so only tailnet clients
(`100.64.0.0/10`) reach it; everyone else gets a `403`. This is the same pattern as the other
private services (hive/hermes/openclaw). Two layers, by design:

1. **DNS-only (grey-cloud) A record** for `TERMIX_DOMAIN` → your tailnet IP, so public resolvers
   can't even find the host.
2. **Caddy `@tailnet` gate** (the real enforcement) — blocks a Host-header request sent straight
   to your public IP, which the DNS record alone wouldn't stop.

Termix has its own native multi-user auth, so the **first registered user becomes admin** — create
your account on first visit, then disable open registration in the Termix admin panel.

## How to Run

```bash
cp .env.example .env   # set TERMIX_DOMAIN
docker compose -f stack.yml --env-file .env up -d
```

## Files

- `stack.yml` - Termix server plus the optional `guacd` sidecar, gated through `caddy-docker-proxy`.
- `.env.example` - Public placeholder values only.

## Environment Variables

- `TERMIX_DOMAIN` - Hostname Caddy serves Termix on (single host).
- `CADDY_INGRESS_NETWORK` - Shared Caddy ingress network name (default `caddy`).
- `TERMIX_TAG` - Termix image tag. `latest` tracks upstream; pin before upgrades for stricter control.
- `GUACD_TAG` - Guacamole daemon image tag.
- `TERMIX_PORT` - Internal HTTP port Termix listens on (default `8080`).
- `GUACD_HOST` - Internal hostname of the `guacd` sidecar (default `guacd`).

## Persistence

Termix stores its SQLite DB, generated keys, and settings under `/app/data` in the `termix_data`
volume. Back it up to preserve users, saved SSH connections, and generated secrets.

## Reference Docs

- Termix Docker install: https://docs.termix.site/install/server/docker/
- Termix reverse proxy notes: https://docs.termix.site/setup/reverse-proxy/
