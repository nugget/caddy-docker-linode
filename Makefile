PROJECT=caddy-with-linode-dns
REGISTRY=docker.io
LIBRARY=nugget

image=$(REGISTRY)/$(LIBRARY)/$(PROJECT)

platforms=linux/amd64,linux/arm64

# Pre-populate our OCI labels from our base image
FROM_IMAGE=caddy:latest
include ./tools/make/oci-annotations-inherited.Makefile

# https://github.com/opencontainers/image-spec/blob/main/annotations.md
OCI_IMAGE_URL="https://hub.docker.com/repository/docker/nugget/caddy-with-linode-dns"
OCI_IMAGE_SOURCE="https://github.com/nugget/caddy-with-linode-dns"
OCI_IMAGE_AUTHORS="David 'nugget' McNett <contact@nugget.info>"
OCI_IMAGE_VENDOR="David 'nugget' McNett <contact@nugget.info>"
OCI_IMAGE_TITLE="Caddy with dns.providers.linode"
OCI_IMAGE_DESCRIPTION=$(FROM_IMAGE_DESCRIPTION)"\nThis is a custom build with the dns.providers.linode module and fish shell added to the official distribution."
OCI_IMAGE_DOCUMENTATION=$(OCI_IMAGE_SOURCE)
OCI_IMAGE_LICENSES=$(FROM_IMAGE_LICENSES)
OCI_IMAGE_BASE_NAME=$(FROM_IMAGE)
OCI_IMAGE_REF_NAME=$(image)

include ./tools/make/oci-annotations-environment.Makefile
include ./tools/make/oci-annotations-vcs-git.Makefile
include ./tools/make/oci-docker-build-args.Makefile


prodtag=latest
devtag=dev
builder=builder-$(PROJECT)

.PHONY: debug buildx clean pullbase image prod push run stop

debug:
	@echo "#"
	@echo "# $(image)"
	@echo "#"
	@echo "# created: $(OCI_IMAGE_CREATED)"
	@echo "#"
	@echo 

buildx:
	@echo "# making: buildx"
	@echo making target buildx
	docker buildx create --name $(builder)
	docker buildx use $(builder)
	docker buildx install
	@echo 

clean:
	@echo "# making: clean"
	-docker buildx rm $(builder)
	@echo 

pullbase:
	@echo "# making: pullbase"
	@echo making target pullbase
	docker pull $(FROM_IMAGE)
	@echo 
	@echo "$(FROM_IMAGE) Labels:"
	@docker inspect $(FROM_IMAGE) | jq '.[0].Config.Labels' 
	@echo
	@echo "$(FROM_IMAGE) Tags:"
	@echo "{ $(FROM_IMAGE_TAGLIST) }"
	@echo 

image: debug pullbase
	@echo "# making: image"
	docker context use default
	docker build $(oci-build-labels) -t $(image):$(devtag) . --load
	docker inspect $(image):$(devtag) | jq '.[0].Config.Labels' 
	@echo 

push: debug pullbase buildx
	@echo "# making: prod"
	docker buildx use $(PROJECT)
	docker buildx build $(oci-build-labels) -t $(image):$(prodtag) $(FROM_IMAGE_TAGARGS) --platform=$(platforms) --push . 
	docker buildx rm $(builder)
	docker pull $(image):$(prodtag)
	docker inspect $(image):$(prodtag) | jq '.[0].Config.Labels' 
	@echo 

run: stop image 
	@echo "# making: run"
	docker run --name $(PROJECT) -d -p 8080:80 $(image):$(devtag)
	open http://localhost:8080/
	docker logs -f $(PROJECT)
	@echo

stop:
	@echo "#making: stop"
	-docker container stop $(PROJECT)
	-docker container rm $(PROJECT)
	@echo
