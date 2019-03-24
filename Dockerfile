# vim: ft=dockerfile
FROM golang:alpine as builder

ARG VERSION="1.2.3"

RUN apk --no-cache add git && \
  go get -d github.com/cozy/cozy-stack && \
  cd ${GOPATH}/src/github.com/cozy/cozy-stack && \
  git checkout tags/${VERSION} && \
  go install -i

FROM moritzheiber/alpine-base

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
