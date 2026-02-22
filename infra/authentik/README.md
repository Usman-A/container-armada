# Authentik

Authentik is an identity provider and SSO platform. This stack deploys Authentik with:

- `postgresql` for persistent database storage.
- `server` for the web/API service.
- `worker` for background jobs.


## Starting the stack:

```bash 
docker compose -f stack.yml --env-file .env up -d
```

## Files

- `stack.yml` - Compose stack definition.
- `.env.example` - Required environment variable template.
- `./data`, `./certs`, `./custom-templates` - Bind mount paths used by the stack.

## Required Environment Variables

Set these in your `.env` file (do not commit it):

- `PG_USER`
- `PG_PASS`
- `AUTHENTIK_SECRET_KEY`
- `COMPOSE_PORT_HTTP`
- `COMPOSE_PORT_HTTPS`


```bash
cp .env.example .env
```

## Notes

- Default ports are `9000` (HTTP) and `9443` (HTTPS).
- The Authentik server and worker image defaults to `ghcr.io/goauthentik/server:2025.12.4`.
