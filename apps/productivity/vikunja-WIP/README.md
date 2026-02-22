# Vikunja-WIP [Linked with Authentik]

This stack is set up to be linked with Authentik using OpenID Connect (OIDC).

## Files

- `stack.yml` - Vikunja + PostgreSQL stack definition.
- `config.template.yml` - Template used to generate `config.yml`.
- `generate-config.sh` - Script used by the `vikunja_config` init service to generate `config.yml`.
- `.env.example` - Required environment variable template.

## Required Environment Variables

Set these in your local `.env` file (do not commit it):

- `VIKUNJA_DB_PASSWORD`
- `VIKUNJA_SERVICE_PUBLICURL`
- `COMPOSE_PORT_HTTP`
- `COMPOSE_PORT_HTTPS`
- `VIKUNJA_OIDC_AUTH_URL`
- `VIKUNJA_OIDC_CLIENT_ID`
- `VIKUNJA_OIDC_CLIENT_SECRET`

## How to Run

```bash
cp .env.example .env
docker compose -f stack.yml --env-file .env up -d
```

The `vikunja_config` init service runs automatically and generates `config.yml` before Vikunja starts.
In Portainer, this works with stack environment variables and does not require mounting a `.env` file into containers.

## OIDC Setup Notes

OIDC values are sourced from `.env` and written into `config.yml` by the `vikunja_config` init service.
The generated config is stored in a Docker volume and mounted into Vikunja at `/etc/vikunja/config.yml`.

With this config, the provider key is `authentik`, so the callback path in Vikunja is:

- `/auth/openid/authentik`

## Port Notes

- `COMPOSE_PORT_HTTP` maps directly to Vikunja on container port `3456`.
- `COMPOSE_PORT_HTTPS` is a second host port mapped to the same container port, useful if you want an alternate external entrypoint.
- For real TLS, terminate HTTPS at a reverse proxy and forward to Vikunja.

## Troubleshooting

- If you see `permission denied` errors for `/app/vikunja/files`, this stack runs Vikunja as `root` to avoid UID/GID mismatch with persistent volumes.
- If you see `No config file found`, check `docker compose -f stack.yml --env-file .env logs vikunja_config` and confirm config generation succeeded.
- If you use a reverse proxy, make sure `VIKUNJA_SERVICE_PUBLICURL` in `.env` matches your external URL.
- In Portainer, confirm `vikunja_config` exits successfully before/with `vikunja` startup and verify it wrote `/work/config.yml` in the shared `vikunja_config` volume.

## Reference Docs

- Vikunja OIDC config examples: https://vikunja.io/docs/openid-example-configurations/
- Vikunja config options (auth/openid): https://vikunja.io/docs/config-options/
- Authentik OAuth2/OpenID provider docs: https://docs.goauthentik.io/add-secure-apps/providers/oauth2/
- Authentik and applications overview: https://docs.goauthentik.io/add-secure-apps/
