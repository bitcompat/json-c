# syntax=docker/dockerfile:1.18
ARG RUN_TESTS=0

FROM docker.io/bitnami/minideb:bullseye as builder

ARG PACKAGE=json-c
ARG TARGET_DIR=common
# renovate: datasource=github-tags depName=json-c/json-c
ARG BUILD_VERSION=0.16-20220414
ARG REF=json-c-$BUILD_VERSION
ARG RUN_TESTS

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN install_packages ca-certificates curl git build-essential g++ cmake tar gzip bzip2 pkg-config

RUN <<EOT bash
    mkdir -p /opt/src/${PACKAGE}-build
    mkdir -p /opt/bitnami/${TARGET_DIR}

    cd /opt/src
    git clone -b ${REF} https://github.com/json-c/json-c.git json-c
    cd json-c-build
    cmake -DCMAKE_INSTALL_PREFIX=/opt/bitnami/${TARGET_DIR} -DCMAKE_BUILD_TYPE=Release ../json-c
    make -j\$(nproc)
    if [[ "${RUN_TESTS}" != "0" ]]; then
      make test USE_VALGRIND=0
    fi
    make install

    mkdir -p /opt/bitnami/${TARGET_DIR}/licenses
    cp -f ../json-c/COPYING /opt/bitnami/${TARGET_DIR}/licenses/${PACKAGE}-${BUILD_VERSION}.txt
EOT

FROM docker.io/bitnami/minideb:bullseye as stage-0

COPY --link --from=builder /opt/bitnami /opt/bitnami
