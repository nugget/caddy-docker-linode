FROM caddy:builder AS build

RUN xcaddy build latest --output /build/caddy --with github.com/caddy-dns/linode

FROM caddy:latest AS baselayer

FROM scratch
COPY --from=baselayer . /
RUN apk add --no-cache fish ca-certificates libcap mailcap

COPY --from=build build/caddy /usr/bin/caddy
RUN cp -p /usr/share/caddy/index.html /usr/share/caddy/index-original.html
COPY webroot/index.html /usr/share/caddy/index.html

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp
EXPOSE 2019

WORKDIR /srv

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]

ARG OCI_IMAGE_CREATED
ARG OCI_IMAGE_AUTHORS
ARG OCI_IMAGE_URL
ARG OCI_IMAGE_DOCUMENTATION
ARG OCI_IMAGE_SOURCE
ARG OCI_IMAGE_VERSION
ARG OCI_IMAGE_REVISION
ARG OCI_IMAGE_VENDOR
ARG OCI_IMAGE_LICENSES
ARG OCI_IMAGE_REF_NAME
ARG OCI_IMAGE_TITLE
ARG OCI_IMAGE_DESCRIPTION
ARG OCI_IMAGE_BASE_DIGEST
ARG OCI_IMAGE_BASE_NAME

LABEL org.opencontainers.image.created="${OCI_IMAGE_CREATED}"
LABEL org.opencontainers.image.authors="${OCI_IMAGE_AUTHORS}"
LABEL org.opencontainers.image.url="${OCI_IMAGE_URL}"
LABEL org.opencontainers.image.documentation="${OCI_IMAGE_DOCUMENTATION}"
LABEL org.opencontainers.image.source="${OCI_IMAGE_SOURCE}"
LABEL org.opencontainers.image.version="${OCI_IMAGE_VERSION}"
LABEL org.opencontainers.image.revision="${OCI_IMAGE_REVISION}"
LABEL org.opencontainers.image.vendor="${OCI_IMAGE_VENDOR}"
LABEL org.opencontainers.image.licenses="${OCI_IMAGE_LICENSES}"
LABEL org.opencontainers.image.ref.name="${OCI_IMAGE_REF_NAME}"
LABEL org.opencontainers.image.title="${OCI_IMAGE_TITLE}"
LABEL org.opencontainers.image.description="${OCI_IMAGE_DESCRIPTION}"
LABEL org.opencontainers.image.base.digest="${OCI_IMAGE_BASE_DIGEST}"
LABEL org.opencontainers.image.base.name="${OCI_IMAGE_BASE_NAME}"
