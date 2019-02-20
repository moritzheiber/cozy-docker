# vim: ft=dockerfile
FROM moritzheiber/alpine-base
ARG VERSION="1.2.1"
ARG CHECKSUM="ee976a8b7dd20c66afe5653b8decd2cf222b89b004ec7fe55131fbeae552d4e4"

RUN apk --no-cache add git imagemagick curl ca-certificates && \
  curl -Lo /tmp/cozy-stack https://github.com/cozy/cozy-stack/releases/download/${VERSION}/cozy-stack-linux-amd64 && \
  echo "${CHECKSUM}  /tmp/cozy-stack" | sha256sum -c - && \
  install -m0755 -o root -g root /tmp/cozy-stack /usr/bin/cozy-stack && \
  rm -f /tmp/cozy-stack && \
  adduser -h /cozy -s /bin/sh -D cozy && \
  install -d -o cozy -g cozy /cozy/.cozy /cozy/storage && \
  apk --no-cache del --purge curl

ADD config/cozy.yml /cozy/.cozy/

EXPOSE 8080
USER cozy

VOLUME /cozy/storage

CMD ["cozy-stack","serve","--config","/cozy/.cozy/cozy.yml"]
