# Hermes Agent (Nous Research)

Self-hosted self-improving AI agent: gateway + supervised dashboard (**9119**), built-in **Kanban**,
persistent **memory/skills**, cron, sandboxed terminal, and a loopback OpenAI-compatible API (8642,
not proxied). **Tailscale-gated** at the Caddy edge (off-tailnet → 403); the dashboard also runs its
own basic auth. LLM = **DeepSeek**.

## Deploy
1. Secrets in 1Password (`homelab/hermes`): `dashboard_password`, `deepseek_api_key`, optional
   `telegram_bot_token`. Sync into Komodo.
2. Komodo Environment (or `deployments/infra/hermes/hermes.env`): `HERMES_DOMAIN`,
   `CADDY_INGRESS_NETWORK=caddy`, `HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=[[HERMES_DASHBOARD_PASSWORD]]`,
   `DEEPSEEK_API_KEY=[[HERMES_DEEPSEEK_API_KEY]]`, `HERMES_TIMEZONE=America/Toronto`.
3. Deploy → dashboard at `https://${HERMES_DOMAIN}` (tailnet only, then Hermes basic auth).

## Authentik SSO (native OIDC) — optional upgrade from basic auth
Create an Authentik **OAuth2/OIDC provider + application** for Hermes, then set in the stack:
`HERMES_DASHBOARD_OIDC_ISSUER=https://auth.usmanasad.ca/application/o/hermes/` and
`HERMES_DASHBOARD_OIDC_CLIENT_ID=<id>` (drop the basic-auth vars). This makes Hermes itself do SSO; you
can then relax the Caddy forward_auth to a plain `reverse_proxy` if you want SSO handled solely by Hermes.

## Security
`TERMINAL_ENV=local` keeps agent commands inside this container (no host docker.sock, unprivileged).
For dev access, mount a **scoped** repos/vault dir + dedicated deploy key. Switch to `TERMINAL_ENV=docker`
only deliberately. Tailscale-gating is the safer exposure for a shell-capable agent.
