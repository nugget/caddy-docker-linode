PROJECT=caddy-with-linode-dns
REGISTRY=docker.io
LIBRARY=nugget

image=$(REGISTRY)/$(LIBRARY)/$(PROJECT)

platforms=linux/amd64,linux/arm64

# https://github.com/opencontainers/image-spec/blob/main/annotations.md
OCI_IMAGE_URL="https://hub.docker.com/repository/docker/nugget/caddy-with-linode-dns"
OCI_IMAGE_AUTHORS="David 'nugget' McNett <contact@nugget.info>"
OCI_IMAGE_DESCRIPTION="caddy-docker base with dns.providers.linode module and fish shell added"

include ./tools/make/oci-annotations-environment.Makefile
include ./tools/make/oci-annotations-vcs-git.Makefile
include ./tools/make/oci-docker-build-args.Makefile

prodtag=latest
devtag=dev

.PHONY: debug buildx clean pullcaddy image release run stop

debug:
	@echo ""
	@echo $(image)
	@echo ""

buildx:
	docker buildx create --name $(PROJECT)
	docker buildx use $(PROJECT)
	docker buildx install

clean:
	docker buildx rm caddybuilder

pullcaddy:
	docker pull caddy:latest
	docker pull caddy:builder

image: debug pullcaddy
	docker build $(oci-build-labels) -t $(image):$(devtag) . 
	docker inspect $(image):$(devtag) | jq '.[0].Config.Labels' 

release: debug pullcaddy buildx
	docker buildx use $(PROJECT)
	docker buildx build $(oci-build-labels) -t $(image):$(prodtag) --platform=$(platforms) --push . 
	docker pull $(image):$(prodtag)
	docker inspect $(image):$(prodtag) | jq '.[0].Config.Labels' 

run: stop image 
	docker run --name $(PROJECT) -d -p 8080:80 $(image):$(devtag)
	open http://localhost:8080/
	docker logs -f $(PROJECT)

stop:
	-docker container stop $(PROJECT)
	-docker container rm $(PROJECT)
