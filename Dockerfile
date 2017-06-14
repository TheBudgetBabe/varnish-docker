FROM alpine:latest

MAINTAINER E Camden Fisher <fish@fishnix.net>

WORKDIR /

ARG VARNISH_VERSION=4.1.3-r0

ENV VARNISH_BACKEND_HOST localhost
ENV VARNISH_BACKEND_PORT 8080

ENV VARNISH_THREAD_POOLS 4
ENV VARNISH_THREAD_POOL_MIN 10
ENV VARNISH_THREAD_POOL_MAX 300
ENV VARNISH_THREAD_POOL_TIMEOUT 300

ENV VARNISH_CLI_TIMEOUT 86400

ENV VARNISH_STORAGE "malloc,1G"
ENV VARNISH_SECRET "changeme"

ENV VARNISH_VCL_CONF /configs/default.vcl
ENV VARNISH_LISTEN_PORT 6081
ENV VARNISH_ADMIN_LISTEN_PORT 6082

RUN set -ex \
    && apk update \
    && apk add bash curl \
    && apk add varnish=${VARNISH_VERSION}

RUN mkdir -p /secrets /configs /var/lib/varnish \
    && chown -R nobody /secrets /configs /var/lib/varnish

ADD entrypoint.sh /
ADD default.vcl ${VARNISH_VCL_CONF}

EXPOSE 6081
EXPOSE 6082

USER nobody

HEALTHCHECK CMD curl --fail http://localhost:${VARNISH_LISTEN_PORT}/ping || exit 1

ENTRYPOINT ./entrypoint.sh
