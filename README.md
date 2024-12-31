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

[nugget/caddy-with-linode-dns]: https://hub.docker.com/repository/docker/nugget/caddy-with-linode-dns/general
[caddy-docker]: https://hub.docker.com/_/caddy
[dns.providers.linode]: https://github.com/caddy-dns/linode
[fish shell]: https://fishshell.com
[Caddy]: https://caddyserver.com
