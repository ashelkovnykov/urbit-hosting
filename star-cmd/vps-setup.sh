# ==============================================================================
# Setup script for a VPS which will host an Urbit ship and a website at the
#   same domain.
#
# Notes:
#   - script should be run as root
# ==============================================================================

# stop on error
set -e

# create system user to run ship
adduser --system web

# setup environment variables
export AMES_PORT=34343
export SSH_PORT=<your ssh port>
export MEM_IN_MB=<your server memory in MB>
export PLANET_NAME=<your planet name>
export CMD_ROOT=<path to this repo on VPS>

# open firewall
ufw allow 80/udp
ufw allow 443/tcp
ufw allow $AMES_PORT/udp
ufw allow $SSH_PORT/tcp
ufw enable

# add swap
touch /var/swap.img
chmod 600 /var/swap.img
dd if=/dev/zero of=/var/swap.img bs=1024k count=$MEM_IN_MB
mkswap /var/swap.img
swapon /var/swap.img
echo '/var/swap.img    none    swap    sw    0    0' >> fstab

# install prerequisites
apt update
apt install -y debian-keyring debian-archive-keyring apt-transport-https ca-certificates curl gnupg lsb-release

# install docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install docker-ce

# install docker-compose
curl -L "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# add system user to docker group
usermod -aG docker web

# create persistent docker volumes
docker volume create caddy_data
docker volume create caddy_config
docker volume create $PLANET_NAME

# copy control files to /home/web/
cp "$CMD_ROOT/Caddyfile" /home/web/
cp "$CMD_ROOT/docker-compose.yml" /home/web/
cp "$CMD_ROOT/start.sh" /home/web/
cp "$CMD_ROOT/stop.sh" /home/web/
cp -r "$CMD_ROOT/sites" /home/web/
chown -R web:docker /home/web/*

# copy planet key to volume
docker pull busybox
docker run -v $PLANET_NAME:/data --name copier busybox true
docker cp "$CMD_ROOT/$PLANET_NAME.key" copier:"/data/$PLANET_NAME.key"
docker rm copier
