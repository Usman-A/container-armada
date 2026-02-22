#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")"

log() {
  printf '%s %s\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "$*"
}

if [ ! -f "config.template.yml" ]; then
  log "ERROR: Missing config.template.yml"
  exit 1
fi

TEMPLATE_PATH="${TEMPLATE_PATH:-config.template.yml}"
OUTPUT_PATH="${OUTPUT_PATH:-config.yml}"

if [ ! -f "$TEMPLATE_PATH" ]; then
  log "ERROR: Missing template file at $TEMPLATE_PATH"
  exit 1
fi

# Load .env when present (local workflow), otherwise rely on process environment
# (works for Compose/Portainer init-service execution).
if [ -f ".env" ]; then
  log "INFO: Loading variables from .env"
  set -a
  . ./.env
  set +a
else
  log "INFO: No .env file present, using process environment only"
fi

required_vars="
VIKUNJA_SERVICE_PUBLICURL
VIKUNJA_OIDC_AUTH_URL
VIKUNJA_OIDC_CLIENT_ID
VIKUNJA_OIDC_CLIENT_SECRET
"

for var_name in $required_vars; do
  eval "var_value=\${$var_name:-}"
  if [ -z "$var_value" ]; then
    log "ERROR: Missing required variable: $var_name"
    exit 1
  fi
done

log "INFO: Template path: $TEMPLATE_PATH"
log "INFO: Output path: $OUTPUT_PATH"
log "INFO: Public URL: $VIKUNJA_SERVICE_PUBLICURL"
log "INFO: OIDC auth URL: $VIKUNJA_OIDC_AUTH_URL"
log "INFO: OIDC client ID length: $(printf '%s' "$VIKUNJA_OIDC_CLIENT_ID" | wc -c | tr -d ' ')"
log "INFO: OIDC client secret length: $(printf '%s' "$VIKUNJA_OIDC_CLIENT_SECRET" | wc -c | tr -d ' ')"

escape_sed() {
  printf '%s' "$1" | sed -e 's/[\/&]/\\&/g'
}

public_url_escaped="$(escape_sed "$VIKUNJA_SERVICE_PUBLICURL")"
auth_url_escaped="$(escape_sed "$VIKUNJA_OIDC_AUTH_URL")"
client_id_escaped="$(escape_sed "$VIKUNJA_OIDC_CLIENT_ID")"
client_secret_escaped="$(escape_sed "$VIKUNJA_OIDC_CLIENT_SECRET")"

umask 077
sed \
  -e "s/__VIKUNJA_SERVICE_PUBLICURL__/$public_url_escaped/g" \
  -e "s/__VIKUNJA_OIDC_AUTH_URL__/$auth_url_escaped/g" \
  -e "s/__VIKUNJA_OIDC_CLIENT_ID__/$client_id_escaped/g" \
  -e "s/__VIKUNJA_OIDC_CLIENT_SECRET__/$client_secret_escaped/g" \
  "$TEMPLATE_PATH" > "$OUTPUT_PATH"

if [ ! -s "$OUTPUT_PATH" ]; then
  log "ERROR: Generated config file is missing or empty: $OUTPUT_PATH"
  exit 1
fi

log "INFO: Generated config file from template"
log "INFO: Generated file details:"
ls -la "$OUTPUT_PATH"
log "INFO: Generated config preview (secrets redacted):"
sed \
  -n \
  -e 's/clientsecret:.*/clientsecret: "<redacted>"/g' \
  -e 's/clientid:.*/clientid: "<redacted>"/g' \
  -e '1,80p' \
  "$OUTPUT_PATH"
