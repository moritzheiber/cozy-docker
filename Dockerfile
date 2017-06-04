FROM ubuntu:xenial

ENV VERSION="2017M1-alpha" \
  CHECKSUM="34cc8fd67f5cbc26fbb9f523342b2604781f51bef418bd2b54bf7b81d6b8fc74"

RUN apt-get update -qq && apt-get install -y curl ca-certificates && \
  useradd -d /cozy -s /bin/sh -mU cozy && \
  curl -o /tmp/cozy-stack -Lv https://github.com/cozy/cozy-stack/releases/download/${VERSION}/cozy-stack-linux-amd64-${VERSION} && \
  install -m0755 -o root -g root /tmp/cozy-stack /usr/bin/cozy-stack && \
  rm -f /tmp/cozy-stack

EXPOSE 8080
USER cozy

CMD ["cozy-stack","serve","--couchdb-url","http://couchdb:5984/"]
