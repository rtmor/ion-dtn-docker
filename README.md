# ION-DTN Docker Container

The ION-DTN container is a pre-built ION image solution designed to support rapid ION node deployment and extend testing capabilities. In addition, through the extension of this container image with Docker Compose, multi-node testing environments are available in a matter of seconds.

## Table of Contents

1. [Installation](#installation)
   - [Requirements](#requirements)
   - [DockerHub](#dockerhub)
   - [From Source](#build-source)
2. [Usage](#usage)
   - [Configuration](#configuration)
   - [Examples](#examples)
3. [Multi-Node Environments](#multi-node-with-docker-compose)
   - [Configuration](#configuration)
   - [Networking](#networking)

## Quick Start

This repository includes a Makefile to simplify the deployment of the following multi-node demonstrations:

#### 2-Node ION Ping

```bash
make up-example1
```

#### 5-Node ION Exit Node

```bash
make up-example2
```

## Installation

#### Requirements

- Docker _(latest recommended)_
- Docker Compose _(for multi-node operation)_

### DockerHub

Pull image directly from DockerHub.

`docker pull rtmoran/ion-dtn`

### Build Source

Clone repository and build from Dockerfile.

```
docker clone git@github.com:rtmor/ion-container.git
cd ion-container
docker build -t local/ion-dtn:latest -f build/Dockerfile .
```

## Usage

### Configuration

By default, ION-DTN container will look to `/usr/local/etc/ion/ion.rc` to load the node's configuration file unless other wise defined through the use of the `ION_CONFIG_PATH` environment variable.

Local ION configuration files may be passed to a ION container on run through the use of a Docker mount point. This can be achieved by specifiying the `-v | [--volume]` Docker flag on run.

### Examples

**Start Node:** \
`docker run -v ${LOCAL_CONFIG_DIR}:/usr/local/etc/ion -it --rm local/ion-dtn:latest /usr/local/etc/ion/${CONFIG_NAME}.rc`

**Start Node & Run Command:** \
`docker run -v ${LOCAL_CONFIG_DIR}:/usr/local/etc/ion -it --rm local/ion-dtn:latest bping ipn:10.1 ipn:11.1 -C`

## Multi-Node with Docker Compose

Multi-node testing environments can be achieved through the use of Docker-Compose configuration files. Included within this repository are several such examples residing within the `deploy` directory.

### Configuration

Basic requirements for a functional ION DTN container service includes the definition of a local mount point, from which an ION configuration file may be loaded with the use of the `ION_CONFIG_PATH` environment variable.

For instance, the following is a simple Docker-Compose configuration for two nodes taken from `deploy/example1`:

```
services:
  ion-node-1:
    image: local/ion-dtn:latest
    ports:
      - "1113/udp"
    environment:
      ION_CONFIG_PATH: "/usr/local/etc/ion/host10.rc"
    volumes:
      - ../../config/two-node:/usr/local/etc/ion:ro
    command:
      [
        "bpecho", "ipn:10.1", "-C"
      ]
    networks:
      - ion-net
  ion-node-2:
    image: local/ion-dtn:latest
    ports:
      - "1113/udp"
    environment:
      ION_CONFIG_PATH: "/usr/local/etc/ion/host11.rc"
    volumes:
      - ../../config/two-node:/usr/local/etc/ion:ro
    command:
      [
        "bping", "-C", "ipn:11.1", "ipn:10.1"
      ]
    networks:
      - ion-net
networks:
  ion-net:
```

### Networking

A Docker-Compose networking interface can be defined for node services through the use of the `networks` configuration object.

Multi-node resolving is accomplished through the addressing of foreign nodes by their hostname within the local node's ION configuration file contact plans. A node's hostname is, by default, assigned to match the Docker-Compose configuration service key-value under which it resides.

#### docker-compose.yaml

```docker-compose
...
services:
  ion-node-1:
    image: local/ion-dtn:latest
...
```

#### node-2.rc

```
...
## begin ltpadmin
1 32

a span 11 32 32 1400 10000 1 'udplso ion-node-2:1113' 300
a span 10 32 32 1400 10000 1 'udplso ion-node-1:1113' 300

s 'udplsi ion-node-2:1113'
## end ltpadmin
...
```

More information coming...
