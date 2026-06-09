# Beszel — server & container monitoring

Hub + agent for lightweight metrics (CPU / memory / disk / network + per-container
stats, history, alerts). Web UI at `${BESZEL_DOMAIN}`, gated by **Authentik forward
auth** via caddy-docker-proxy.

## Architecture
- **beszel** (hub): web UI + PocketBase DB. On the `caddy` (ingress) and
  `beszel-internal` networks.
- **beszel-agent** (local): bridge-networked on `beszel-internal`; the hub reaches it
  at `beszel-agent:45876`. **Why not host networking** (the upstream default): the host
  firewall drops bridge→host traffic on 45876, so the hub couldn't reach a host-mode
  agent. On the shared bridge the traffic stays in Docker's FORWARD chain. CPU/RAM/disk
  are still host-accurate (shared kernel `/proc` + `pid: host`).

The hub connects **out** to each agent over SSH (port 45876), authenticating with the
hub's SSH key (the agent's `KEY`, which is the hub's *public* key — not secret).

## First-run setup (already done for this deployment)
1. Hub deployed; admin created: `docker exec beszel /beszel superuser upsert <email> <pw>`
   → password stored in 1Password (`homelab/beszel`).
2. Agent `KEY` = the hub's public key: `ssh-keygen -y -f /beszel_data/id_ed25519`
   (read from the `beszel_data` volume), written to `BESZEL_AGENT_KEY` in the deploy env.
3. Systems registered in the hub (name / host / port 45876): `vps` → `beszel-agent`,
   `unicron` → `100.70.62.36`, `nemesis` → `100.88.138.128` (home Proxmox hosts, reached
   over Tailscale).

## Adding another host (e.g. a home Proxmox node or VM)
Install the agent as a systemd service (SSH mode — the hub dials in over Tailscale):
```bash
ssh root@<host> 'bash -s' <<'EOF'
curl -fsSL https://github.com/henrygd/beszel/releases/latest/download/beszel-agent_linux_amd64.tar.gz \
  | tar -xz -C /usr/local/bin beszel-agent
cat >/etc/systemd/system/beszel-agent.service <<UNIT
[Unit]
Description=Beszel Agent
After=network-online.target
[Service]
Environment=LISTEN=45876
Environment="KEY=<HUB_PUBLIC_KEY>"
ExecStart=/usr/local/bin/beszel-agent
Restart=on-failure
[Install]
WantedBy=multi-user.target
UNIT
systemctl enable --now beszel-agent
EOF
```
Then in the hub UI: **Add System** → host = the node's Tailscale IP, port = `45876`.
(The hub container reaches tailnet IPs via the VPS host's Tailscale routing.)

## Notes
- Exposure: `BESZEL_DOMAIN` behind Authentik forward_auth. Optional future: wire Beszel's
  native OIDC to Authentik for true single-login (no separate Beszel password).
- The hub caches a system's host at connect time — after changing a system's host, restart
  the `beszel` container to force a reconnect.
