#
# git
#
FROM alpine/git:v2.30.2 AS git

#
# Docker Builder
#
FROM docker:20.10.10 AS docker
RUN --mount=type=cache,target=/var/cache/apk \
    set -ex \
    && apk add grep

ENV DOCKER_BUILDKIT 1

#
# Wait For It
#
FROM alpine:3.14.0 AS wait-for-it
ENV WAIT_FOR_IT /wait-for-it.sh
RUN --mount=type=cache,target=/var/cache/apk \
    set -ex \
    && apk add bash \
    && apk add curl --virtual .build-deps \
    && curl https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -o ${WAIT_FOR_IT} \
    && chmod +x ${WAIT_FOR_IT} \
    && apk del .build-deps

#
# Docker Compose
#
FROM docker/compose:1.29.2 as docker-compose

#
# GitHub CLI
#
FROM alpine:3.14.0 AS github-cli
ENV GITHUB_CLI_VERSION 1.11.0

RUN --mount=type=cache,target=/var/cache/apk \
    set -ex \
    && apk add git \
    && apk add curl --virtual .build-deps \
    && curl -L https://github.com/cli/cli/releases/download/v${GITHUB_CLI_VERSION}/gh_${GITHUB_CLI_VERSION}_linux_amd64.tar.gz | tar xz \
    && mv gh_${GITHUB_CLI_VERSION}_linux_amd64/bin/gh /bin/gh \
    && chmod +x /bin/gh \
    && apk del .build-deps \
    && rm -rf gh_${GITHUB_CLI_VERSION}_linux_amd64
