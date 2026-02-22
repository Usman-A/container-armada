#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")"

if [ ! -f "config.template.yml" ]; then
  echo "Missing config.template.yml."
  exit 1
fi

# Load .env when present (local workflow), otherwise rely on process environment
# (works for Compose/Portainer init-service execution).
if [ -f ".env" ]; then
  set -a
  . ./.env
  set +a
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
    echo "Missing required variable in .env: $var_name"
    exit 1
  fi
done

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
  config.template.yml > config.yml

echo "Generated config.yml from config.template.yml"
