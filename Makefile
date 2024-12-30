.PHONY: debug public tag

PROJECT=nugget/caddy-dns-linode
REGISTRY=registry.hollowoak.net

# https://github.com/opencontainers/image-spec/blob/main/annotations.md

OCI_IMAGE_URL="https://github.com/"
OCI_IMAGE_AUTHORS="David 'nugget' McNett <contact@nugget.info>"
OCI_IMAGE_DESCRIPTION="caddy-docker base layer with dns.providers.linode module"

include ./tools/make/oci-annotations-environment.Makefile
include ./tools/make/oci-annotations-vcs-git.Makefile

include ./tools/make/oci-docker-build-args.Makefile

PRODTAG=latest
LOCALTAG=local

IMAGE=$(REGISTRY)/$(PROJECT)

BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

.PHONY: debug
debug:
	@echo ""
	@echo $(IMAGE):$(TAG)
	@echo $(oci-build-labels)
	@echo ""

image: debug
	docker buildx create --name caddybuilder --use
	docker buildx install
	docker buildx build $(oci-build-labels) -t $(IMAGE):$(PRODTAG) --platform=linux/amd64,linux/arm64 --push . 
	docker buildx rm caddybuilder
	docker pull $(IMAGE):$(PRODTAG)
	docker inspect $(IMAGE):$(PRODTAG) | jq '.[0].Config.Labels' 

updatebase:
	docker pull caddy:latest
	docker pull caddy:builder

buildlocal: debug updatebase
	docker build $(oci-build-labels) -t $(IMAGE):$(LOCALTAG) .
	docker inspect $(IMAGE):$(LOCALTAG) | jq '.[0].Config.Labels' 

runlocal: stoplocal buildlocal public
	docker run --name nugget-info -d -p 8080:80 $(IMAGE):$(LOCALTAG)
	open http://localhost:8080/

stoplocal:
	-docker container stop nugget-info
	-docker container rm nugget-info

public:
	cd hugo && hugo  --cleanDestinationDir 

deploy: public buildimage
	docker tag $(IMAGE):$(TAG) $(IMAGE):$(PRODTAG)
	docker push $(IMAGE):$(PRODTAG)
