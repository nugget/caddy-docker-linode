# caddy-docker-linode

This repository contains the build tooling used to create the
[nugget/caddy-with-linode-dns][image-repo] Docker images published on Docker Hub.

The published images are faithful copies of [caddy-docker] with the following
changes:

* I am only building for linux/amd64, linux/arm64 currently

* `/usr/bin/caddy` is built with [dns.providers.linode][module]

* `/usr/bin/fish` is installed to make forensics more pleasant if
   you find yourself inside the container for any reason

For anything else the base behavior from [Caddy] should be unchanged.

[image-repo]: https://hub.docker.com/repository/docker/nugget/caddy-with-linode-dns/general
[caddy-docker]: https://hub.docker.com/_/caddy
[module]: https://github.com/caddy-dns/linode
[Caddy]: https://caddyserver.com
