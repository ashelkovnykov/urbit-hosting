# Urbit Hosting

This repo contains configurable files which can used to set up a server (local or VPS) to host one or more websites and
Urbit ships at the same time using Docker, Caddy, and MinIO.

Note that it assumes you already have:
- Access to a local server or VPS
  - The server is assumed to be some common variant of Linux, e.g. Ubuntu 18.04
- Access to a user account with `sudo` privileges
- SSH set up on the server
- One or more domain names that you will use to access the server remotely

## Directory Layout

```
|- star-cmd: Raw VPS setup files
   |- sites: Root directory for websites
   |  |-  my-website: Dummy website folder; should be replaced by one or more
   |                  folders, each of which is root for a website
   |- Caddyfile: Caddy setup file; see Caddy documentation
   |    https://caddyserver.com/docs/caddyfile
   |- compose.yml: docker-compose setup file; see docker-compose documentation
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

## Setup

1. Clone this repo to the server
2. Fill out the required fields in the files:
    1. `Caddyfile`
       1. Fill in the fields with your custom domain(s)
       2. You may need to add more fields (using the same pattern) if you're
          hosting multiple ships or websites.
    2. `vps-setup.sh`
        1. line `17`
        2. line `20`
        3. You may need/want to modify the default values on lines `22` - `31`.
           If you modify line `22`, you'll also need to modify the `launch.sh`
           and `thwart.sh` scripts to match the new system user.
        4. Note the comments on lines `18` and `23` if you plan to host
           multiple ships
    3. `compose.yml`
       1. line `35`
       2. line `60`
       3. line `83`
       4. If you're hosting more than one ship, you'll need to note the comments
          on lines `38` - `55`. You will also need to clone lines `83` - `84`
          for each additional ship.
3. If you're not using MinIO, you can delete `minio_bucket_policy.json`, all of
   the MinIO info in `Caddyfile`, and lines `20` - `34`, line `58`, and line
   `67`.
4. Run `vps-setup.sh` as root
5. (Optional) Move the `launch.sh` and `thwart.sh` scripts somewhere in your
   regular user account. They can be used as a shorthand for spinning your web
   server up/down.

### DNS

Add wildcard subdomain `A` rules that point to the server IP for each of the
mappings in your `Caddyfile`. For example, if your `Caddyfile` looks like this
after setup:
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

minio.urbit.io images.minio.urbit.io {
  reverse_proxy web-minio-1:9000
}
```
then in your domain provider settings, you will need to set the following `A`
records for `urbit.io` (which you must own):
- `www`
- `@`
- `zod`
- `console.minio`
- `minio`
- `images.minio`

## Acknowledgements

Thank you to [`~datder-sonnet`](https://github.com/tomholford) for base files,
working examples, and tech support!

Thank you to [`~sitful-hatred`](https://github.com/yapishu) for the
[initial article](https://subject.network/posts/caddyserver-urbit-tls/)
that inspired all of this work!
