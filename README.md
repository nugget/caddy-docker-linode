# caddy-docker-linode

This repository contains the build tooling used to create the
[nugget/caddy-with-linode-dns] Docker images published on Docker Hub.

The published images are faithful copies of [caddy-docker] with the following
changes:

* I am only building for linux/amd64, linux/arm64 currently

* `/usr/bin/caddy` is built with [dns.providers.linode]

* [fish shell] is installed to make forensics more pleasant if
   you find yourself inside the container for any reason

For anything else the base behavior from [Caddy] should be unchanged.

### Docker Compose example

Here's a sample service definition which goes in a file named `compose.yaml`.
In order for the Linode DNS letsencrypt function to work, we need to supply our 
running container with our Linode V4 API key.

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
      - "172.28.10.42:80:80"
      - "172.28.10.42:443:443"
      - "172.28.10.42:443:443/udp"
      - "192.168.1.42:2019:2019"
      - "100.80.207.67:2019:2019"
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

```secrets/acme-dns.Caddyfile
acme_dns linode {LINODE_V4_API_KEY}
```

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
[fish shell]: https://fishshell.com
[Caddy]: https://caddyserver.com
