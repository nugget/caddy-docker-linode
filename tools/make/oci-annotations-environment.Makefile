# Populate OCI annotation variables from the build environment.
#
# https://github.com/opencontainers/image-spec/blob/main/annotations.md

OCI_IMAGE_CREATED="$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")"
