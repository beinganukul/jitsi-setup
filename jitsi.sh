#!/bin/bash
cd ~/
mkdir jitsi
cd jitsi
url=jitsi.anukul.com.np
curl https://api.github.com/repos/jitsi/docker-jitsi-meet/releases/latest | grep "tarball_url" | grep -Eo 'https://[^\"]*' | xargs wget -O - | tar -xzv --strip-components 1
sed "s/#PUBLIC_URL=https:\/\/meet.example.com/PUBLIC_URL=https:\/\/$url/" env.example  > .env
echo "DESKTOP_SHARING_FRAMERATE_MIN=15 
DESKTOP_SHARING_FRAMERATE_MAX=60 
RESOLUTION_WIDTH_MIN=1280 
RESOLUTION_WIDTH=1920 
RESOLUTION_MINIMUM=720 
RESOLUTION=1080 
ENABLE_P2P=ture
ENABLE_IPV6=ture" >> .env
./gen-passwords.sh
mv docker-compose.yml dockercompose
sed '/^services:.*/a\ \ \ \ traefik:\n\ \ \ \ \ \ \ \ image: traefik:latest\n\ \ \ \ \ \ \ \ command:\n\ \ \ \ \ \ \ \ \ \ \ \ - "--api.insecure=true"\n\ \ \ \ \ \ \ \ \ \ \ \ - "--providers.docker=true"\n\ \ \ \ \ \ \ \ \ \ \ \ - "--providers.docker.exposedbydefault=true"\n\ \ \ \ \ \ \ \ \ \ \ \ - "--entrypoints.websecure.address=:443"\n\ \ \ \ \ \ \ \ \ \ \ \ - "--entrypoints.websecure=:80"\n\ \ \ \ \ \ \ \ \ \ \ \ - "--certificatesresolvers.myresolver.acme.tlschallenge=true"\n\ \ \ \ \ \ \ \ \ \ \ \ - "--certificatesresolvers.myresolver.acme.email=jitsi@anukul.com.np"\n\ \ \ \ \ \ \ \ \ \ \ \ - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"\n\ \ \ \ \ \ \ \ ports:\n\ \ \ \ \ \ \ \ \ \ \ \ - 443:443\n\ \ \ \ \ \ \ \ volumes:\n\ \ \ \ \ \ \ \ \ \ \ \ - ./data/traefik/letsencrypt:/letsencrypt\n\ \ \ \ \ \ \ \ \ \ \ \ - /var/run/docker.sock:/var/run/docker.sock:ro\n\ \ \ \ \ \ \ \ networks:\n\ \ \ \ \ \ \ \ \ \ \ \ meet.jitsi:' dockercompose > dockercompose.yml
sed '/^\ \ \ \ web:.*/a\ \ \ \ \ \ \ \ labels:\n\ \ \ \ \ \ \ \ \ \ \ \ - "traefik.enable=true"\n\ \ \ \ \ \ \ \ \ \ \ \ - "traefik.http.routers.jitsi.rule=Host(`'"$url"'`)"\n\ \ \ \ \ \ \ \ \ \ \ \ - "traefik.http.routers.jitsi.entrypoints=websecure"\n\ \ \ \ \ \ \ \ \ \ \ \ - "traefik.http.routers.jitsi.tls.certresolver=myresolver"\n\ \ \ \ \ \ \ \ \ \ \ \ - "traefik.http.services.jitsi.loadbalancer.server.port=443"\n\ \ \ \ \ \ \ \ \ \ \ \ - "traefik.http.services.jitsi.loadbalancer.server.port=80"' dockercompose.yml > docker-compose.yml
rm dockercompose.yml dockercompose
sudo docker-compose up -d
