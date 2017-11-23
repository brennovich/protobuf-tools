FROM alpine:3.6
MAINTAINER brennolncosta@gmail.com

ARG JOBS=1

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
ENV PROTOBUF_REVISION 3.5.0
RUN curl -sLO https://github.com/google/protobuf/releases/download/v${PROTOBUF_REVISION}/protoc-${PROTOBUF_REVISION}-linux-x86_64.zip \
  && unzip protoc-${PROTOBUF_REVISION}-linux-x86_64.zip -d ./usr/local \
  && rm protoc-${PROTOBUF_REVISION}-linux-x86_64.zip

ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8
RUN ALPINE_GLIBC_BASE_URL="https://github.com/andyshinn/alpine-pkg-glibc/releases/download" \
    && ALPINE_GLIBC_PACKAGE_VERSION="2.23-r1" \
    && ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" \
    && ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" \
    && ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" \
    && apk --update add bash \
    && apk add --no-cache --virtual=build-dependencies ca-certificates \
    && apk add bash \
    && apk add tzdata \
    && cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime \
    && echo America/Sao_Paulo > /etc/timezone \
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

ENV JAVA_VERSION=8 \
    JAVA_UPDATE=131 \
    JAVA_BUILD=11 \
    ORACLE_TOKEN=d54c1d3a095b4ff2b6607d096fa80163 \
    JAVA_HOME="/opt/jdk"

RUN apk add --no-cache --virtual=java-dependencies ca-certificates \
    && cd "/tmp" \
    && curl -sL --header "Cookie: oraclelicense=accept-securebackup-cookie;" -O "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/${ORACLE_TOKEN}/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" \
    && tar -xzvf "jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz"  \
    && mkdir -p $JAVA_HOME \
    && mv jdk1*/* $JAVA_HOME \
    && ln -s "$JAVA_HOME/bin/"* "/usr/bin/" \
    && rm -rf "$JAVA_HOME/"*src.zip \
    && rm -rf $JAVA_HOME/*src.zip \
      $JAVA_HOME/lib/missioncontrol \
      $JAVA_HOME/lib/visualvm \
      $JAVA_HOME/lib/*javafx* \
      $JAVA_HOME/jre/lib/plugin.jar \
      $JAVA_HOME/jre/lib/ext/jfxrt.jar \
      $JAVA_HOME/jre/bin/javaws \
      $JAVA_HOME/jre/lib/javaws.jar \
      $JAVA_HOME/jre/lib/desktop \
      $JAVA_HOME/jre/plugin \
      $JAVA_HOME/jre/lib/deploy* \
      $JAVA_HOME/jre/lib/*javafx* \
      $JAVA_HOME/jre/lib/*jfx* \
      $JAVA_HOME/jre/lib/amd64/libdecora_sse.so \
      $JAVA_HOME/jre/lib/amd64/libprism_*.so \
      $JAVA_HOME/jre/lib/amd64/libfxplugins.so \
      $JAVA_HOME/jre/lib/amd64/libglass.so \
      $JAVA_HOME/jre/lib/amd64/libgstreamer-lite.so \
      $JAVA_HOME/jre/lib/amd64/libjavafx*.so \
      $JAVA_HOME/jre/lib/amd64/libjfx*.so \
    && apk del java-dependencies \
    && rm -rf "/tmp/"*

# Build [protoc-gen-doc](https://github.com/estan/protoc-gen-doc) against configured revision
#
# protobuf plugin to generate docs in markdown, html, docbook and pdf
#
ENV PROTOC_GEN_DOC_REVISION 1.0.0
RUN curl -sLO https://github.com/pseudomuto/protoc-gen-doc/releases/download/v${PROTOC_GEN_DOC_REVISION}/protoc-gen-doc-${PROTOC_GEN_DOC_REVISION}.linux-amd64.go1.9.tar.gz \
  && tar -zxvf protoc-gen-doc-${PROTOC_GEN_DOC_REVISION}.linux-amd64.go1.9.tar.gz \
  && cp protoc-gen-doc-${PROTOC_GEN_DOC_REVISION}.linux-amd64.go1.9/protoc-gen-doc /usr/local/bin/ \
  && rm -rf protoc-gen-doc-*

# Build [ScalaPB](https://github.com/trueaccord/ScalaPB) plugin
#
# This plugin make possible to generate Scala's case class for a given proto.
#
# Important: Java is a dependency!
#
ENV SCALA_PB_VERSION 0.6.6
RUN curl -sLO "https://github.com/trueaccord/ScalaPB/releases/download/v$SCALA_PB_VERSION/scalapbc-$SCALA_PB_VERSION.zip" \
  && unzip "scalapbc-$SCALA_PB_VERSION.zip" \
  && mv "scalapbc-$SCALA_PB_VERSION" /usr/local/lib/scalapbc \
  && ln -s /usr/local/lib/scalapbc/bin/scalapbc /usr/local/bin/scalapbc

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
ENV RUST_PROTOBUF_VERSION 1.4.2
ENV RUSTPATH /rust
RUN apk add cargo \
  && mkdir $RUSTPATH \
  && cargo install --root $RUSTPATH --vers $RUST_PROTOBUF_VERSION protobuf
ENV PATH $RUSTPATH/bin:$PATH

# Cleaning up
RUN apk del \
  autoconf \
  automake \
  build-base \
  curl \
  git \
  libtool \
  unzip \
  && rm -rf /var/cache/apk/*

