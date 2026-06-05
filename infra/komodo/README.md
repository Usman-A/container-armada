# Komodo

Container and stack management platform for multi-host Docker environments.

**Upstream:** https://komo.do | https://github.com/moghtech/komodo

## Components

| Service | Purpose |
|---|---|
| `komodo-core` | Web UI + API server. Manages stacks, repos, alerts. |
| `komodo-ferretdb` | Lightweight MongoDB-compatible database backed by SQLite. |
| `komodo-periphery` | Agent on each managed Docker host. Core talks to periphery to deploy stacks. |

## How to Run

1. Copy `.env.example` to `.env`.
2. Generate secrets:
   ```bash
   openssl rand -hex 32   # run twice — one for KOMODO_PASSKEY, one for JWT_SECRET
   ```
3. Fill in `KOMODO_PASSKEY`, `KOMODO_JWT_SECRET`, and `KOMODO_HOST` in `.env`.
4. Deploy:
   ```bash
   docker compose -f stack.yml up -d
   ```
5. Open `http://<host>:9120` and complete initial setup.

## Deploying stacks from a Git repo

1. In Komodo UI → **Resources → Git Providers** — add your GitHub account (PAT with `repo` scope for private repos; not needed for public repos).
2. **Resources → Stacks → New Stack** → set the repo URL and path to the `stack.yml`.
3. Secrets for that stack go in **Resources → Variables/Secrets** inside Komodo — never in the repo.
4. Enable auto-deploy on push (webhook or polling) to redeploy when the repo changes.

## Multi-host setup

To manage a **remote host**, deploy only the `komodo-periphery` service on that host (separate compose file or same file with a profile), then in Komodo UI → **Servers** → add the host IP and port (`PERIPHERY_PORT`). The passkey must match on both sides.

## Notes

- FerretDB uses SQLite under the hood (`/state` volume) — no external Postgres or Mongo needed.
- The `komodo-periphery` container mounts `/proc` and the Docker socket; keep it behind your firewall.
- `KOMODO_PASSKEY` is shared between core and all periphery agents — rotate it by updating all instances simultaneously.
- Architecture: x86_64 and ARM64 supported.
