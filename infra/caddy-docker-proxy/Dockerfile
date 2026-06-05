# Custom caddy-docker-proxy build that bundles the Cloudflare DNS plugin,
# required for ACME DNS-01 challenges (needed when sites sit behind the
# Cloudflare proxy, where TLS-ALPN/HTTP challenges don't work).
ARG CADDY_VERSION=2.11.3

FROM caddy:${CADDY_VERSION}-builder AS builder
RUN xcaddy build \
    --with github.com/lucaslorentz/caddy-docker-proxy/v2 \
    --with github.com/caddy-dns/cloudflare

FROM caddy:${CADDY_VERSION}-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
CMD ["caddy", "docker-proxy"]
