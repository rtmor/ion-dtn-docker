# ION-DTN Docker image file
# Ryan T. Moran
#
FROM debian:bullseye-slim AS builder

LABEL "org.rtmoran.version"="0.1"
LABEL "org.rtmoran.maintainer"="Ryan T. Moran <ryan@rtmoran.org>"
LABEL "org.rtmoran.description"="https://github.com/rtmor/ion-container"

ENV ION_SRC="ipnsig-pwg-main" \
    ION_VERSION="ion-4.1.0"

WORKDIR /build

ADD build/${ION_SRC}.zip .

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get upgrade && \
    apt-get install --no-install-recommends -y build-essential unzip

RUN export BUILD_DIR=$(mktemp -d) && \
    unzip ${ION_SRC}.zip -d ${BUILD_DIR} && \
    cd ${BUILD_DIR}/${ION_SRC}/${ION_VERSION} && \
    ./configure --prefix=/usr/local/src && \
    make -j$((`getconf _NPROCESSORS_ONLN` + 1)) && \
    make install && \
    ldconfig

FROM debian:bullseye-slim

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get upgrade && \
    apt-get install --no-install-recommends -y ca-certificates gosu

COPY --from=builder /usr/local/src /usr/local/src
COPY config/sample.rc /usr/local/etc/ion/ion.rc

WORKDIR /service

RUN groupadd -r ionserv && \
    useradd -r -g ionserv ionserv && \
    chown -R ionserv:ionserv /service

ENV PATH=/usr/local/src/bin:${PATH}

EXPOSE 1113/udp

COPY build/docker-entrypoint.sh /usr/bin

ENTRYPOINT [ "docker-entrypoint.sh" ]
