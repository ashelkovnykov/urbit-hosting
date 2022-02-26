# Urbit Hosting

This repo contains configurable files which can used to set up a VPS server to host one or more websites and Urbit
planets at the same time, using Docker and Caddy.

## Directory Layout

```
|- example: Main files from 'star-cmd' filled in with dummy data as an example
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

## Usage

1. Purchase and set up a VPS
2. Clone this repo
3. Modify the files to match your environment
    - At a minimum, this means lines 17 - 20 in `vps-setup.sh`, lines 22, 29, and 44 in `docker-compose.yml`, and most of
      `Caddyfile`
    - You may need to modify more of these files (e.g. if you're hosting multiple planets, multiple websites, or no
      websites)
    - You may also need to change the distribution/version specific settings in `vps-setup.sh`
4. Run `vps-setup.sh` as root
5. (Optional) Move `launch.sh` and `thwart.sh` to a location of your choice for use by a non-system user with `sudo`
   privileges
6. Call `start.sh` (or `launch.sh`) when you're ready

## Acknowledgements

Thank you to `~datder-sonnet` for working example files and tech support!
