# Vikunja [Linked with Authentik]

This stack is set up to be linked with Authentik using OpenID Connect (OIDC).

## Files

- `stack.yml` - Vikunja + PostgreSQL stack definition.
- `config.yml` - Vikunja OIDC provider config for Authentik.
- `.env.example` - Required environment variable template.

## Required Environment Variables

Set these in your local `.env` file (do not commit it):

- `VIKUNJA_DB_PASSWORD`
- `VIKUNJA_SERVICE_PUBLICURL`

## How to Run

```bash
cp .env.example .env
docker compose -f stack.yml --env-file .env up -d
```

## OIDC Setup Notes

Update these placeholders in `config.yml`:

- `authurl` -> your Authentik application URL.
- `clientid` -> Authentik OAuth2 client ID.
- `clientsecret` -> Authentik OAuth2 client secret.

With this config, the provider key is `authentik`, so the callback path in Vikunja is:

- `/auth/openid/authentik`

## Reference Docs

- Vikunja OIDC config examples: https://vikunja.io/docs/openid-example-configurations/
- Vikunja config options (auth/openid): https://vikunja.io/docs/config-options/
- Authentik OAuth2/OpenID provider docs: https://docs.goauthentik.io/add-secure-apps/providers/oauth2/
- Authentik and applications overview: https://docs.goauthentik.io/add-secure-apps/
