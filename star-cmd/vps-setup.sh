# ==============================================================================
# Setup script for a VPS which will host an Urbit ship and a website at the
#   same domain.
#
# Notes:
#   - script should be run as root
# ==============================================================================

# stop on error
set -e

#
# environment variables
#

# regular user account w/ sudo privileges
export DAILY_USER=<user account>
# add more ships here if running multiple ships
#   e.g. SHIPS=sampel-palnet littel-possum rinsed-dishes
export SHIPS=<ship name>
# system user to own files; default 'web'
export SYSTEM_USER=web
# add more ports here if running multiple ships
#   e.g. AMES_PORTS=34343 45454 12121
export AMES_PORTS=34343
# ssh port, if accessing server remotely (as with VPS)
export SSH_PORT=22
# size of swap file
export MEM_IN_MB=6000
# path to root dir of this repo locally
export CMD_ROOT=/root/star-cmd

#
# main script
#

# create system user to run ship
adduser --system $SYSTEM_USER

# open firewall
ufw allow 80/udp
ufw allow 443/tcp
for PORT in $AMES_PORTS; do ufw allow $PORT/udp; done
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
curl -L "https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# add system user to sudo group
usermod -aG sudo $SYSTEM_USER

# create persistent docker volumes
sudo docker volume create caddy_data
sudo docker volume create caddy_config

# copy control files to system user home
cp "$CMD_ROOT/Caddyfile" /home/$SYSTEM_USER/
cp "$CMD_ROOT/docker-compose.yml" /home/$SYSTEM_USER/
cp "$CMD_ROOT/start.sh" /home/$SYSTEM_USER/
cp "$CMD_ROOT/stop.sh" /home/$SYSTEM_USER/
cp -r "$CMD_ROOT/sites" /home/$SYSTEM_USER/
chown -R $SYSTEM_USER:$SYSTEM_USER /home/$SYSTEM_USER/*

# copy control files to daily user home
cp "$CMD_ROOT/launch.sh" /home/$DAILY_USER/
cp "$CMD_ROOT/thwart.sh" /home/$DAILY_USER/
chown -R $DAILY_USER:$DAILY_USER /home/$DAILY_USER/*

for SHIP in $SHIPS;
do
  # create persistent docker volume for ship
  sudo docker volume create $SHIP

  # copy planet key to volume
  sudo docker pull busybox
  sudo docker run -v $SHIP:/data --name copier busybox true
  sudo docker cp "$CMD_ROOT/$SHIP.key" copier:"/data/$SHIP.key"
  sudo docker rm copier
done

# copy SSH pub keys to authorized_keys
mkdir -p /home/$DAILY_USER/.ssh
cp "$CMD_ROOT/authorized_keys" /home/$DAILY_USER/.ssh/

# hardening

## first, backup the sshd_config file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

## disable password login
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

## disable root login
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config

## install + configure fail2ban
apt install fail2ban
cp "$CMD_ROOT/jail.conf" /etc/fail2ban/jail.local
systemctl enable fail2ban
systemctl restart fail2ban

# done :)
echo "Done! Rebooting in 10 seconds..."
sleep 10
reboot
