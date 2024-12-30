# Populate OCI Git-derived annotation variables from the build environment.
#
# https://github.com/opencontainers/image-spec/blob/main/annotations.md

GIT ?= $(shell which git)

OCI_IMAGE_REVISION?="$(shell $(GIT) rev-parse HEAD)"
OCI_IMAGE_VERSION?="$(shell $(GIT) describe --always --long --tags --dirty)"
