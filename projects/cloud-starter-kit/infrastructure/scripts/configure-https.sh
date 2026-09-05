#!/usr/bin/env bash

set -euo pipefail

DOMAIN="${1:-demo.legatratechnologies.com}"

echo "Configuring HTTPS for ${DOMAIN}"

export DEBIAN_FRONTEND=noninteractive

# Ensure Docker is installed and running.
if ! command -v docker >/dev/null 2>&1; then
  apt-get update
  apt-get install -y docker.io
fi

systemctl enable --now docker

# Run the application only on localhost.
docker pull nginx:alpine

docker rm --force cloud-starter-web 2>/dev/null || true

docker run \
  --detach \
  --name cloud-starter-web \
  --restart unless-stopped \
  --publish 127.0.0.1:8080:80 \
  --volume /opt/cloud-starter/html:/usr/share/nginx/html:ro \
  nginx:alpine

# Wait for the backend before configuring the proxy.
for attempt in {1..10}; do
  if curl --fail --silent --show-error http://127.0.0.1:8080 >/dev/null; then
    echo "Backend is healthy."
    break
  fi

  if [[ "${attempt}" -eq 10 ]]; then
    echo "Backend failed to become healthy." >&2
    exit 1
  fi

  sleep 2
done

# Install Caddy when it is not already installed.
if ! command -v caddy >/dev/null 2>&1; then
  apt-get update
  apt-get install -y \
    debian-keyring \
    debian-archive-keyring \
    apt-transport-https \
    curl \
    gnupg

  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
    | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
    > /etc/apt/sources.list.d/caddy-stable.list

  chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg
  chmod o+r /etc/apt/sources.list.d/caddy-stable.list

  apt-get update
  apt-get install -y caddy
fi

cat > /etc/caddy/Caddyfile <<EOF
${DOMAIN} {
    reverse_proxy 127.0.0.1:8080
}
EOF

caddy fmt --overwrite /etc/caddy/Caddyfile
caddy validate --config /etc/caddy/Caddyfile

systemctl enable caddy
systemctl restart caddy

echo
echo "Backend:"
curl -I http://127.0.0.1:8080

echo
echo "HTTPS configuration complete for:"
echo "https://${DOMAIN}"

