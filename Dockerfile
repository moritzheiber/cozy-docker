# vim: ft=dockerfile
FROM ubuntu as mime

ARG DEBIAN_FRONTEND="non-interactive"

RUN apt update && \
  apt install -y mime-support

FROM golang:1.12.5-alpine3.9 as builder

ARG VERSION="1.2.8"

RUN apk --no-cache add git && \
  git clone https://github.com/cozy/cozy-stack.git \
    ${GOPATH}/src/github.com/cozy/cozy-stack && \
  cd ${GOPATH}/src/github.com/cozy/cozy-stack && \
  git checkout tags/${VERSION} && \
  go get -v -d . && \
  go install -i -v

FROM alpine:edge

COPY --from=mime /etc/mime.types /etc/mime.types
COPY --from=builder /go/bin/cozy-stack /tmp/cozy-stack
RUN apk --no-cache add git imagemagick && \
  install -m0755 -o root -g root /tmp/cozy-stack /usr/bin/cozy-stack && \
  rm -f /tmp/cozy-stack && \
  adduser -h /cozy -s /bin/sh -D cozy && \
  install -d -o cozy -g cozy /cozy/.cozy /cozy/storage

ADD config/cozy.yml /cozy/.cozy/

EXPOSE 8080
USER cozy

VOLUME /cozy/storage

CMD ["cozy-stack","serve","--config","/cozy/.cozy/cozy.yml"]
