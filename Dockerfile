FROM ubuntu:focal

ENV ION_SRC="ipnsig-pwg-main"
ENV ION_VERSION="ion-4.1.0"
ENV ION_CONFIG_FILE="sample.rc"

WORKDIR /ion_build

ADD ${ION_SRC}.zip .

RUN chown -R 1000.1000 .


RUN DEBIAN_FRONTEND=noninteractive apt --no-install-recommends update && \
    apt upgrade && \
    apt install build-essential unzip -y

RUN export BUILD_DIR=$(mktemp -d) && \
    unzip ${ION_SRC}.zip -d ${BUILD_DIR} && \
    cd ${BUILD_DIR}/${ION_SRC}/${ION_VERSION} && \
    ./configure --prefix=/usr/local/src && \
    make -j$((`nproc` + 1)) && \
    make install && \
    ldconfig

# USER 1000:1000

ENV PATH=/usr/local/src/bin:${PATH}

EXPOSE 1113/udp

COPY docker-entrypoint.sh /usr/bin
ENTRYPOINT ["docker-entrypoint.sh"]


# CMD ["ionstart"]
