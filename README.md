# Container Armada 🚢

A centralized, version-controlled repository for managing OCI stacks. 


My main goal with this repository is to have a centralized place to store my container configs. A lot of the time when trying to deploy based off of existing ones, there are small issues here and there that I have to figure out before getting a working stack going. The idea here is to keep *"working"* ones so that I can easily redeploy in the future, or if people need help with getting things set up, they can use my configs.

I mainly deploy these with Portainer (yes, I could use Kube, but I don't need that complexity yet), so having a public repo with these templates makes that easier for me. On changes, I can auto-deploy, etc.

## Pre-requisites
These stacks are built around the [OCI (Open Container Initiative)](https://opencontainers.org/about/overview/) standard. OCI is an open governance structure—originally established by Docker and other industry leaders—that creates universal, open industry standards for container formats and runtimes. Because of this standardization, any OCI-compliant container image can run on any OCI-compliant runtime without being locked into a single vendor's ecosystem.

The most common way to deploy these is using Docker and Docker Compose. However, because these are standard OCI containers, you can also easily use open-source alternatives like Podman, which is highly popular for its daemonless architecture and rootless container security.

To use these configs, you will need:

- A container runtime installed (like Docker or Podman).
- A basic understanding of how to use `docker-compose` or the equivalent in your chosen runtime.

## Structure
We have a few different categories of stacks, organized into folders:

* `/infra`
    - Core networking, proxy, and system services.
* `/apps` 
    - User-facing applications and services.
* `/databases`  
    - Standalone database instances.
* `/misc`       
    - Miscellaneous or experimental stacks.

Within these folders, each stack should be organized as follows:

```/stack-name
    ├── stack.yml 
    ├── .env.example (optional, for environment variable templates)
    └── README.md
```

If a stack folder ends with `-WIP`, it is not yet confirmed working.

## How the stacks fit together (reverse proxy, TLS & auth)

Three shared conventions wire these stacks into one system:

**1. Ingress via `caddy-docker-proxy`.** `infra/caddy-docker-proxy` runs a custom
Caddy build (Caddy + the Cloudflare DNS plugin) that watches the Docker socket and
configures itself from container **labels**. To expose a service you join the shared
external `caddy` network and add labels:

```yaml
labels:
  caddy: ${MY_DOMAIN}                       # domain kept out of the repo via env
  caddy.reverse_proxy: "{{upstreams 8080}}" # container's address on the caddy net
```

`{{upstreams <port>}}` resolves to the container's IP on the `caddy` network, so **no
host ports are needed**. Real domains never live in the repo — they come from your
private `.env` (`${MY_DOMAIN}`).

**2. TLS via Cloudflare DNS-01.** Caddy obtains real Let's Encrypt certs using the
Cloudflare DNS-01 challenge (`CLOUDFLARE_API_TOKEN` + `ACME_EMAIL`). This works even
for hostnames that resolve to a private/Tailscale IP, and for domains proxied through
Cloudflare.

**3. SSO gating via Authentik (forward auth).** To put a service behind Authentik
login, replace the single `reverse_proxy` label with the ordered forward-auth pattern
(see `apps/entertainment/suwayomi` and `apps/productivity/super-productivity`):

```yaml
labels:
  caddy: ${MY_DOMAIN}
  caddy.1_reverse_proxy: "/outpost.goauthentik.io/* http://authentik-server:9000"
  caddy.2_forward_auth: "http://authentik-server:9000"
  caddy.2_forward_auth.uri: "/outpost.goauthentik.io/auth/caddy"
  caddy.2_forward_auth.copy_headers: "X-Authentik-Username X-Authentik-Groups X-Authentik-Email X-Authentik-Name X-Authentik-Uid"
  caddy.3_reverse_proxy: "{{upstreams 8080}}"
```

The `N_` numeric prefixes order the directives. Caddy talks to `authentik-server`
directly over the `caddy` network, so the original `Host` is preserved and Authentik
matches the app by its **proxy provider (forward auth, single application)** external
host. Each gated app needs that provider + an application assigned to the embedded
outpost.

## Image tags & update policy

- Tags are **parameterised** (e.g. `${AUTHENTIK_TAG:-2025.12.4}`) so the default is
  pinned but overridable per-deploy.
- **Stateful / migration-sensitive apps are pinned** (Authentik, Postgres) — bump
  deliberately and read release notes (Authentik runs DB migrations on upgrade).
- **A few roll with upstream**: Nextcloud AIO (`all-in-one:latest`, self-updating by
  design) and Suwayomi (`preview`, its active channel).

## Stacks at a glance

| Stack | Image(s) | Tag policy | Exposure | Auth |
|---|---|---|---|---|
| `infra/caddy-docker-proxy` | custom Caddy + Cloudflare DNS plugin | Caddy pinned `2.11.3` (plugin requires it) | host `:80`/`:443` | — |
| `infra/komodo` | komodo-core/periphery `latest`; ferretdb `2`; postgres-documentdb `latest` | core/periphery `latest` | private — bind to a Tailscale IP via `KOMODO_BIND` | local admin |
| `infra/authentik` | goauthentik/server `2025.12.4`; postgres `16-alpine`; redis `alpine` | **pinned** (DB migrations on upgrade) | `${AUTHENTIK_DOMAIN}` via caddy | it *is* the IdP |
| `apps/productivity/nextcloud` | nextcloud-releases/all-in-one `latest` | self-updating (AIO) | `${NEXTCLOUD_DOMAIN}` via caddy (apache joins `caddy`) | Nextcloud login |
| `apps/productivity/super-productivity` | johannesjo/super-productivity `latest` | `latest` | `${SUPER_PRODUCTIVITY_DOMAIN}` via caddy | **Authentik forward auth** |
| `apps/entertainment/suwayomi` | suwayomi-server `preview`; byparr `latest` | `preview` channel | `${SUWAYOMI_DOMAIN}` via caddy | **Authentik forward auth** |
| `apps/productivity/vikunja` | vikunja `${VIKUNJA_TAG:-0.24.6}`; postgres `16-alpine` | pinned | (template) | native OIDC option |
| `infra/pegaprox` | local build | — | host `:5000` | (template) |

> `vikunja` and `pegaprox` are **templates kept for reference — not currently deployed.**

## Contributing

Contributions are welcome! If you have a stack you'd like to share, please submit a pull request with the following:

1. A clear and descriptive name for the stack.
2. A `stack.yml` file with comments explaining key configurations, with more detailed explanations in the stack's `README.md`.
3. An optional `.env.example` file if your stack requires environment variables.
4. Be sure to test your stack before submitting to ensure it works as expected, and note if there are any hardware architecture limits when using the stack (e.g., ARM vs. x86/AMD64).
5. Add a `README.md` file that provides an overview of the stack, its purpose, and any special instructions for deployment or configuration.
6. Include a `How to Run` section in the stack `README.md` with clear startup guidance (for example: creating `.env` from `.env.example` and a `docker compose` command).
7. Optionally add supporting documentation links in the stack `README.md` so future users can quickly understand and maintain the stack.

## Commit and PR Naming

To keep history easy to scan, use these prefixes in commit messages and PR titles:

- `[New Service][ServiceName]` for first-time stack additions.
- `[Update][ServiceName]` for changes to an existing stack.
- `[Fix][ServiceName]` for bug fixes/regressions in an existing stack.

Examples:

- `[New Service][PegaProx] add initial stack, env template, and README`
- `[Update][Vikunja] add authentik-only auth toggle`
- `[Fix][Authentik] correct postgres healthcheck command`

> **Never commit real `.env` files or secrets in the repository.**
## License

This project is licensed under the MIT License, see the [LICENSE](LICENSE) file for details.
