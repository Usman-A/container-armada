# Authentik

Authentik is an identity provider and SSO platform. This stack deploys Authentik with:

- `postgresql` for persistent database storage.
- `redis` for caching, the task broker, and websockets (required — Authentik will not start without it).
- `server` for the web/API service.
- `worker` for background jobs.


## Starting the stack:

```bash 
docker compose -f stack.yml --env-file .env up -d
```

## Files

- `stack.yml` - Compose stack definition.
- `.env.example` - Required environment variable template.
- `./certs`, `./custom-templates` - Bind mount paths used by the stack.
- `database`, `redis`, `media` - named Docker volumes (DB data, Redis persistence, uploaded media/icons/avatars).

## Required Environment Variables

Set these in your `.env` file (do not commit it):

- `PG_USER`
- `PG_PASS`
- `AUTHENTIK_SECRET_KEY` — keep this stable; rotating it makes secrets stored in the DB unreadable.
- `AUTHENTIK_DOMAIN` — the hostname Caddy serves Authentik on.
- `CADDY_INGRESS_NETWORK` — must match the caddy-docker-proxy stack.

```bash
cp .env.example .env
```

## Notes

- The server listens on `9000` internally; Caddy proxies to it over the shared `caddy` network (no host ports published).
- The Authentik server and worker image defaults to `ghcr.io/goauthentik/server:2025.12.4`.
