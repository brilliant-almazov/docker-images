#
# git
#
FROM alpine/git:v2.30.2 AS git

#
# Docker Builder
#
FROM docker:20.10.7 AS docker
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

#
# OAuth2 Proxy
#
FROM quay.io/oauth2-proxy/oauth2-proxy:v7.1.3 AS oauth2-proxy

CMD "--http-address=:80 --upstream=${UPSTREAM} --reverse-proxy=true --cookie-secret=${COOKIE_SECRET} --email-domain=* --allowed-group=${ALLOWED_GROUP:admin} --provider=keycloak --skip-provider-button=true --redirect-url=https://${SUBDOMAIN}.automagistre.ru/oauth2/callback --scope=openid --client-id=${CLIENT_ID} --client-secret=${CLIENT_SECRET} --login-url=https://auth.automagistre.ru/auth/realms/automagistre/protocol/openid-connect/auth --redeem-url=https://auth.automagistre.ru/auth/realms/automagistre/protocol/openid-connect/token --profile-url=https://auth.automagistre.ru/auth/realms/automagistre/protocol/openid-connect/userinfo --validate-url=https://auth.automagistre.ru/auth/realms/automagistre/protocol/openid-connect/userinfo"
