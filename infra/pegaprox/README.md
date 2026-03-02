# PegaProx

PegaProx is a modern multi-cluster management service for Proxmox VE.
This stack builds the image locally from the included `Dockerfile` and runs it with persistent config and log volumes.

## Files

- `stack.yml` - Compose stack definition for PegaProx.
- `.env.example` - Environment variable template.
- `Dockerfile` - Image build definition used by the stack.

## Required Environment Variables

Set these in your local `.env` file (do not commit it):

- `PEGAPROX_IMAGE` (optional, default `pegaprox`)
- `COMPOSE_PORT_HTTP` (optional, default `5000`)

## How to Run

```bash
cp .env.example .env
docker compose -f stack.yml --env-file .env up -d --build
```

## Notes

- Persistent volumes are mounted at `/app/config` and `/app/logs`.
- The service exposes container port `5000` on `COMPOSE_PORT_HTTP`.
- `no-new-privileges`, `init`, and log rotation are enabled for safer, more stable runtime behavior across different hosts.
