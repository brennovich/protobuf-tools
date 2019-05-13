FROM alpine:3.9

RUN apk add --update \
      autoconf \
      automake \
      build-base\
      curl \
      git \
      go \
      libtool \
      unzip

# Build protobuf against configured revision
#
ENV PROTOBUF_REVISION 3.7.1
RUN curl -sLO https://github.com/google/protobuf/releases/download/v${PROTOBUF_REVISION}/protoc-${PROTOBUF_REVISION}-linux-x86_64.zip \
  && unzip protoc-${PROTOBUF_REVISION}-linux-x86_64.zip -d ./usr/local \
  && chmod +x /usr/local/bin/protoc \
  && chmod -R 755 /usr/local/include/ \
  && rm protoc-${PROTOBUF_REVISION}-linux-x86_64.zip

ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8
RUN ALPINE_GLIBC_BASE_URL="https://github.com/andyshinn/alpine-pkg-glibc/releases/download" \
    && ALPINE_GLIBC_PACKAGE_VERSION="2.27-r0" \
    && ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" \
    && ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" \
    && ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" \
    && apk add --no-cache --virtual=build-dependencies \
      ca-certificates \
      bash \
      tzdata \
    && curl -sL \
        -O "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        -O "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        -O "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" \
    && apk add --no-cache --allow-untrusted \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" \
    && /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true \
    && echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh \
    && apk del glibc-i18n \
    && apk del build-dependencies \
    && rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

RUN apk update
RUN apk fetch openjdk8
RUN apk add openjdk8

# Build [protoc-gen-doc](https://github.com/estan/protoc-gen-doc) against configured revision
#
# protobuf plugin to generate docs in markdown, html, docbook and pdf
#
ENV PROTOC_GEN_DOC_REVISION 1.1.0
RUN curl -sLO https://github.com/pseudomuto/protoc-gen-doc/releases/download/v${PROTOC_GEN_DOC_REVISION}/protoc-gen-doc-${PROTOC_GEN_DOC_REVISION}.linux-amd64.go1.10.tar.gz \
  && tar -zxvf protoc-gen-doc-${PROTOC_GEN_DOC_REVISION}.linux-amd64.go1.10.tar.gz \
  && cp protoc-gen-doc-${PROTOC_GEN_DOC_REVISION}.linux-amd64.go1.10/protoc-gen-doc /usr/local/bin/ \
  && rm -rf protoc-gen-doc-*

# Build [ScalaPB](https://github.com/trueaccord/ScalaPB) plugin
#
# This plugin make possible to generate Scala's case class for a given proto.
#
# Important: Java is a dependency!
#
ENV SCALA_PB_VERSION 0.8.3
RUN curl -sLO "https://github.com/trueaccord/ScalaPB/releases/download/v$SCALA_PB_VERSION/scalapbc-$SCALA_PB_VERSION.zip" \
  && unzip "scalapbc-$SCALA_PB_VERSION.zip" \
  && mv "scalapbc-$SCALA_PB_VERSION" /usr/local/lib/scalapbc \
  && ln -s /usr/local/lib/scalapbc/bin/scalapbc /usr/local/bin/scalapbc \
  && rm "/scalapbc-$SCALA_PB_VERSION.zip"

# Install [protoc-gen-go](https://github.com/protobuf/protoc-gen-go)
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir /go \
  && go get -u github.com/golang/protobuf/protoc-gen-go \
  && go get -u github.com/square/goprotowrap/cmd/protowrap

# Needed shared libraries and tools by protobuf and their plugins
RUN apk --update add \
  bash \
  libstdc++

# Install  [rust-protobuf](https://github.com/stepancheg/rust-protobuf) plugin
ENV RUST_PROTOBUF_VERSION 2.0.3
ENV RUSTPATH /rust
RUN apk add cargo>1.26.0 \
  && mkdir $RUSTPATH \
  && cargo install --all-features --root $RUSTPATH --vers $RUST_PROTOBUF_VERSION protobuf-codegen
ENV PATH $RUSTPATH/bin:$PATH

# Cleaning up
RUN apk del \
  autoconf \
  automake \
  build-base \
  cargo \
  curl \
  git \
  libtool \
  unzip \
  && rm -rf /var/cache/apk/*

RUN mkdir /build
