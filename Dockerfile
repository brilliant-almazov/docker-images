#
# Docker Builder
#
FROM docker:20.10.1 AS docker

ENV DOCKER_BUILDKIT 1

#
# Wait For It
#
FROM alpine:3.12.3 AS wait-for-it
ENV WAIT_FOR_IT /wait-for-it.sh
RUN --mount=type=cache,target=/var/cache/apk \
    set -ex \
    && apk add bash \
    && curl https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -o ${WAIT_FOR_IT} \
    && chmod +x ${WAIT_FOR_IT}
