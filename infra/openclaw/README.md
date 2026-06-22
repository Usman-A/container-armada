# OpenClaw

Self-hosted autonomous AI agent (gateway + web dashboard on **18789**). Driven mainly via chat
(WhatsApp/Telegram/Slack) and the dashboard. **No native SSO** and the dashboard is *not hardened for
public exposure* → this stack is **Tailscale-gated** at the Caddy edge (off-tailnet → 403), same as
`hive.usmanasad.ca`. LLM = **DeepSeek** (OpenAI-compatible).

## Deploy
1. Secrets in 1Password (`homelab/openclaw`): `gateway_token`, `deepseek_api_key`. Sync into Komodo
   (`sync-komodo-secrets.py`) or use the deploy helper.
2. Set the Komodo Environment (or `deployments/infra/openclaw/openclaw.env`): `OPENCLAW_DOMAIN`,
   `CADDY_INGRESS_NETWORK=caddy`, `OPENCLAW_GATEWAY_TOKEN=[[OPENCLAW_GATEWAY_TOKEN]]`,
   `DEEPSEEK_API_KEY=[[OPENCLAW_DEEPSEEK_API_KEY]]`.
3. Deploy. **First run may need a one-time interactive onboarding** to seed the LLM provider profile:
   `docker compose run --rm openclaw dashboard --no-open` (follow the URL once), then normal up.
4. Add the dashboard origin to `gateway.controlUi.allowedOrigins` in
   `/home/node/.openclaw/openclaw.json` (the public domain) if the UI rejects the proxied origin.

## Security
No host docker.sock; unprivileged; `OPENCLAW_SANDBOX=1`; Tailscale-gated. For dev access, mount a
**scoped** repos/vault dir (see commented volumes) and use a dedicated deploy key — never the host
root or docker socket.
