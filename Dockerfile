# vim: ft=dockerfile
FROM ubuntu as mime

ARG DEBIAN_FRONTEND="non-interactive"

RUN apt update && \
  apt install -y mime-support

FROM golang:1.13.0-alpine3.10 as builder

ARG VERSION="1.3.1"
ARG GO111MODULE="on"

RUN apk --no-cache add git && \
  go get -v github.com/cozy/cozy-stack@${VERSION}

FROM moritzheiber/alpine-base

COPY --from=mime /etc/mime.types /etc/mime.types
COPY --from=builder /go/bin/cozy-stack /tmp/cozy-stack
RUN apk --no-cache add git imagemagick && \
  install -m0755 -o root -g root /tmp/cozy-stack /usr/bin/cozy-stack && \
  rm /tmp/cozy-stack && \
  adduser -h /cozy -s /bin/sh -D cozy && \
  install -d -o cozy -g cozy /cozy/.cozy /cozy/storage

ADD config/cozy.yml /cozy/.cozy/

EXPOSE 8080
USER cozy

VOLUME /cozy/storage

CMD ["cozy-stack","serve","--config","/cozy/.cozy/cozy.yml"]
