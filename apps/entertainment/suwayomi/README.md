# Suwayomi

Suwayomi Server lets you read manga from Tachiyomi/Mihon-compatible sources through a self-hosted web interface.

## Usage Scope

This stack is generally designed for single-user use.

If you need remote access, put it behind a reverse proxy and add authentication in front of it (for example, Authentik).

## How to Run

```bash
cp .env.example .env
docker compose -f stack.yml --env-file .env up -d
```

## Files

- `stack.yml` - Suwayomi container stack definition (with optional FlareSolverr sidecar enabled by default).
- `.env.example` - Optional environment variable template.

## Environment Variables

- `SUWAYOMI_PORT` - Host port mapped to container port `4567`.
- `JAVA_TOOL_OPTIONS` - JVM tuning (default in stack: `-Xmx2g`).
- `FLARESOLVERR_ENABLED` - Enables Suwayomi integration with FlareSolverr.
- `FLARESOLVERR_URL` - Internal URL Suwayomi uses to reach FlareSolverr.
- `TZ` - Time zone for FlareSolverr container.

## Notes

- Keep the two volume mounts in the current order in `stack.yml`; the downloads mount must be first.
- By default, no application auth mode is configured in this stack.

## Reference Docs

- Suwayomi Docker setup: https://github.com/Suwayomi/docker-suwayomi
- Suwayomi server Docker variables: https://github.com/Suwayomi/Suwayomi-Server/wiki/Docker-Setup
- Authentik secure app setup: https://docs.goauthentik.io/add-secure-apps/
