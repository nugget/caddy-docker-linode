# caddy-docker-linode

This repository contains the build tooling used to create the
[nugget/caddy-with-linode-dns] Docker images published on Docker Hub.

The published images are faithful copies of [caddy-docker] with the following
changes:

* I am only building for linux/amd64, linux/arm64 currently

* `/usr/bin/caddy` is built with [pineapplehunter/linode-caddy-dns] (forked from [dns.providers.linode])

* [fish shell] is installed to make forensics more pleasant if
   you find yourself inside the container for any reason

For anything else the base behavior from [Caddy] should be unchanged.

### Docker Compose example

Here's a sample service definition which goes in a file named `compose.yaml`.
In order for the Linode DNS letsencrypt function to work, we need to supply our 
running container with our Linode V4 API key, which we do via the [secrets top-level element].

#### docker-compose.yaml

```docker-compose.yaml
services:
  caddy:
    image: nugget/caddy-with-linode-dns:latest
    container_name: Caddy
    secrets:
      - acme-dns
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
      - "2019:2019"
    volumes:
      - $PWD/conf:/etc/caddy
      - $PWD/site:/srv
      - $PWD/log:/log
      - caddy_data:/data
      - caddy_config:/config

volumes:
  caddy_data:
  caddy_config:

secrets:
  acme-dns:
    file: $PWD/secrets/acme-dns.Caddyfile
```

#### acme-dns.Caddyfile

This file will be included by our runtime `Caddyfile` and is exposed inside the
running container at `/run/secrets/acme-dns` by the Docker Compose [secrets
top-level element].

Place this file in `./secrets/acme-dns.Caddyfile` to match the line in the 
`secrets.acme-dns` section of our Caddyfile. Make sure to edit it to include
your Linode V4 API Key instead of the placeholder below:

```secrets/acme-dns.Caddyfile
acme_dns linode {PUT_YOUR_LINODE_V4_API_KEY_HERE}
```

#### Caddyfile

This file should be located in the `conf` directory as defined in your Caddyfile
to be mounted at `/etc/caddy` in the running container. In this example that's
`$PWD/conf/Caddyfile`.

```Caddyfile
# The Caddyfile is an easy way to configure your Caddy web server.
{
	import /run/secrets/acme-dns
}

website.example.com {
	root * /srv
	file_server

	log {
		output file /log/access.log
		format json
	}
}
```

[nugget/caddy-with-linode-dns]: https://hub.docker.com/repository/docker/nugget/caddy-with-linode-dns/general
[caddy-docker]: https://hub.docker.com/_/caddy
[dns.providers.linode]: https://github.com/caddy-dns/linode
[pineapplehunter/linode-caddy-dns]: https://github.com/pineapplehunter/linode-caddy-dns
[fish shell]: https://fishshell.com
[Caddy]: https://caddyserver.com
[secrets top-level element]: https://docs.docker.com/compose/how-tos/use-secrets/
