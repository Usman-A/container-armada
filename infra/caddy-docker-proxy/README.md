# caddy-docker-proxy

Automatic Caddy reverse proxy configured entirely through Docker labels. No Caddyfile required — services self-register by joining a shared network and adding labels.

**Upstream:** https://github.com/lucaslorentz/caddy-docker-proxy

## TL;DR — reverse-proxy ANY container in 3 steps

You never edit a Caddyfile. You just tag the container you want exposed.

1. **Put the container on the `caddy` network.**
2. **Add two labels** — the domain, and the internal port the app listens on.
3. **Redeploy.** Caddy sees the labels, generates the route, and fetches HTTPS automatically.

```yaml
# the only thing you add to any docker-compose service:
    labels:
      caddy: myapp.yourdomain.com
      caddy.reverse_proxy: "{{upstreams 8080}}"   # 8080 = the port INSIDE the container
    networks:
      - caddy

networks:
  caddy:
    name: caddy
    external: true
```

That's it. `{{upstreams 8080}}` auto-resolves to the container — you don't hardcode IPs. Point your DNS (or local `/etc/hosts`) at the Caddy host and the app is live on HTTPS.

**Common variations:**

```yaml
# Multiple domains / subdomains for one app:
caddy: myapp.example.com, www.myapp.example.com

# App speaks HTTPS internally (e.g. self-signed):
caddy.reverse_proxy: "{{upstreams https 8443}}"
caddy.reverse_proxy.transport: http
caddy.reverse_proxy.transport.tls_insecure_skip_verify: ""

# Path-based routing (only proxy /api):
caddy: example.com
caddy.handle_path: /api/*
caddy.handle_path.0_reverse_proxy: "{{upstreams 3000}}"

# Put it behind Authentik SSO (forward_auth):
caddy.forward_auth: authentik-server:9000
caddy.forward_auth.uri: /outpost.goauthentik.io/auth/caddy
```

Proxying something that **isn't** a container (a NAS, a VM, a host service)? You don't need labels — add a plain Caddy site block via a one-off label container or a mounted Caddyfile fragment:

```yaml
# a tiny label-only helper service (no image work needed):
  external-route:
    image: alpine
    command: ["sleep", "infinity"]
    networks: [caddy]
    labels:
      caddy: nas.yourdomain.com
      caddy.reverse_proxy: "192.168.1.50:5000"   # static host:port
```

## TLS behind Cloudflare (DNS-01)

This stack builds a **custom image** (see `Dockerfile`) that bundles the
`caddy-dns/cloudflare` plugin, because when sites sit behind the Cloudflare
proxy (orange cloud) Caddy's default TLS-ALPN/HTTP challenges fail — Cloudflare
terminates TLS. Instead we use the **ACME DNS-01** challenge via the Cloudflare API.

Setup:
1. Create a **scoped Cloudflare API token**: `Zone → DNS → Edit` and `Zone → Zone → Read`
   for each zone you serve (example.com, example.org, ...). Put it in
   `.env` as `CLOUDFLARE_API_TOKEN` (never in the repo).
2. Set each zone's **SSL/TLS mode to Full (strict)** in Cloudflare so the CF→origin hop
   uses the real Let's Encrypt cert Caddy obtains.
3. Set `ACME_EMAIL` in `.env`.
4. Build + deploy:
   ```bash
   docker compose -f stack.yml up -d --build
   ```

The global options (email + `acme_dns cloudflare`) are injected as label-only entries
on the caddy container itself — no manual Caddyfile required.

## How it works

caddy-docker-proxy watches the Docker socket for containers with `caddy.*` labels and dynamically generates a Caddyfile. Caddy handles TLS automatically — here via Let's Encrypt using the Cloudflare DNS-01 challenge.

## How to Run

1. Copy `.env.example` to `.env` and adjust values.
2. Deploy:
   ```bash
   docker compose -f stack.yml up -d
   ```
3. The shared `caddy` network is created automatically on first run.

## Exposing a service through Caddy

Standard pattern: the **web service** joins the shared `caddy` ingress network and adds labels; its **database / private services** sit on a separate per-app network so other apps can't reach them.

```yaml
services:
  myapp:
    image: ...
    labels:
      caddy: app.yourdomain.com
      caddy.reverse_proxy: "{{upstreams 8080}}"   # replace 8080 with the container port
    networks:
      - caddy            # ingress only (shared with Caddy)
      - myapp_internal   # private app<->db network

  db:
    image: postgres:16-alpine
    networks:
      - myapp_internal   # NOT on caddy — unreachable from other apps

networks:
  caddy:
    name: caddy          # must match CADDY_INGRESS_NETWORK
    external: true
  myapp_internal:
```

This gives per-app isolation: a compromise of one app's web tier cannot reach another app's database or files, because those live on separate networks. Optionally add `internal: true` to a DB-only network to also block its outbound internet — but only where no service on it needs egress.

## Nextcloud AIO is the exception

Nextcloud All-in-One manages its own child containers and networking, so you can't put label-based proxying on its dynamically-created Apache container. Instead, proxy to the host port AIO exposes (`NEXTCLOUD_APACHE_PORT`). Add a label to any always-on container, or use a Caddy snippet/site config, pointing at:

```
reverse_proxy <docker-host-ip>:11000
```

See the nextcloud stack README for the exact host IP/port binding.

## Notes

- `CADDY_INGRESS_NETWORK` must be consistent across all stacks that want proxying. Default is `caddy`.
- Caddy stores TLS certificates in the `caddy_data` volume — do not delete it or you'll hit Let's Encrypt rate limits.
- The Docker socket is mounted read-only (`ro`) for security.
- For local/internal-only deployments (no public DNS), you can use a wildcard DNS challenge — see upstream docs for the DNS provider plugins.

## Architecture

- x86_64 and ARM64 supported via the `ci-alpine` tag.
