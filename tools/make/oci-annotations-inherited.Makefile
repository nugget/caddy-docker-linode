FROM_IMAGE_DESCRIPTION=$(shell docker inspect $(FROM_IMAGE) | jq .'[0].Config.Labels."org.opencontainers.image.description"')
FROM_IMAGE_LICENSES=$(shell docker inspect $(FROM_IMAGE) | jq .'[0].Config.Labels."org.opencontainers.image.licenses"')
FROM_IMAGE_VERSION=$(shell docker inspect $(FROM_IMAGE) | jq .'[0].Config.Labels."org.opencontainers.image.version"')

FROM_IMAGE_REPOTAGS=$(shell docker inspect $(FROM_IMAGE) | jq -r '.[0].RepoTags | @tsv' | sed 's,caddy:,,g' |sed 's,\t, ,g')
FROM_IMAGE_TAGLIST=$(shell echo $(FROM_IMAGE_VERSION) | sed 's,^v,,g') $(FROM_IMAGE_REPOTAGS)

FROM_IMAGE_TAGARGS=$(shell echo $(FROM_IMAGE_TAGLIST) | xargs -n 1 -I % echo '-t $(image):%')

