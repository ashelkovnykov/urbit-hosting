# Urbit Hosting

This repo contains configurable files which can used to set up a VPS server to host one or more websites and Urbit
planets at the same time, using Docker, Caddy, and MinIO.

## Directory Layout

```
|- star-cmd: Raw VPS setup files
   |- sites: Root directory for websites
   |  |-  my-website: Dummy website folder; should be replaced by one or more
   |                  folders, each of which is root for a website
   |- Caddyfile: Caddy setup file; see Caddy documentation
   |    https://caddyserver.com/docs/caddyfile
   |- docker-compose.yml: docker-compose setup file; see docker-compose
   |                      documentation
   |    https://docs.docker.com/compose/compose-file/compose-file-v3/#service-configuration-reference
   |- launch.sh: Bash script for non-system user with sudo privileges to launch
   |             Docker containers
   |- start.sh: Docker containers startup script 
   |- stop.sh: Docker containers teardown script
   |- thwart.sh: Bash script for non-system user with sudo privileges to stop
   |             Docker containers
   |- vps-setup: Bash script to setup the VPS environment (install dependencies,
                 enable firewall, etc.)
```

# Setup

## DNS

Add wildcard subdomain `A` rules that point to your VPS' IP for each of the mappings in Caddyfile. For example, if your
Caddyfile looks like this:
```
www.urbit.io {
  redir https://urbit.io permanent
}

urbit.io {
  root * /var/www/my-website
  file_server
}

zod.urbit.io {
  reverse_proxy web-zod-1:80
}

console.minio.urbit.io {
  reverse_proxy web-minio-1:9001
}

minio.ashelkov.com images.minio.urbit.io {
  reverse_proxy web-minio-1:9000
}
```
then in your settings for domain provider, you will need to set the following `A` records for `urbit.io` (which you must
own):
- `www`
- `@`
- `zod`
- `console.minio`
- `minio`
- `images.minio`

## Usage

1. Purchase and set up a VPS
2. Purchase a domain name
3. Clone this repo
4. Modify the files to match your environment
    - At a minimum, this means lines 17 - 20 in `vps-setup.sh`, lines 37, 45, and 61 in `docker-compose.yml`, and most
      of `Caddyfile`
    - If you're hosting multiple websites, multiple planets, no websites, etc., you may need to delete/add additional
      lines
    - If you're not using MinIO, you can delete `minio_bucket_policy.json`, lines 14 - 20 in `Caddyfile`, and lines 22 -
      36 + line 54 + line 63 of `docker-compose.yml`
    - You may also need to change the OS/version specific settings in `vps-setup.sh`
5. Run `vps-setup.sh` as root
6. (Optional) Move `launch.sh` and `thwart.sh` to a location of your choice for use by a non-system user with `sudo`
   privileges
7. Call `start.sh` (or `launch.sh`) when you're ready

## Acknowledgements

Thank you to `~datder-sonnet` for working example files and tech support!
