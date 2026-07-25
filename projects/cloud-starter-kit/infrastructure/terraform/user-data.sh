#!/usr/bin/env bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y docker.io

systemctl enable docker
systemctl start docker

# Ensure the preinstalled Systems Manager agent is running.
systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service || true

mkdir -p /opt/cloud-starter/html

cat > /opt/cloud-starter/html/index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Cloud Starter Kit</title>
  <style>
    body {
      margin: 0;
      min-height: 100vh;
      display: grid;
      place-items: center;
      font-family: Arial, sans-serif;
      background: #0f172a;
      color: #f8fafc;
    }

    main {
      max-width: 720px;
      padding: 48px;
      text-align: center;
    }

    h1 {
      font-size: 3rem;
      margin-bottom: 16px;
    }

    p {
      color: #cbd5e1;
      font-size: 1.2rem;
      line-height: 1.6;
    }
  </style>
</head>
<body>
  <main>
    <h1>Cloud Starter Kit</h1>
    <p>
      This application was deployed on AWS using Terraform,
      Ubuntu, Docker and Nginx.
    </p>
  </main>
</body>
</html>
HTML

docker pull nginx:alpine

docker rm --force cloud-starter-web || true

docker run \
  --detach \
  --name cloud-starter-web \
  --restart unless-stopped \
  --publish 80:80 \
  --volume /opt/cloud-starter/html:/usr/share/nginx/html:ro \
  nginx:alpine
