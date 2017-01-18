FROM alpine:3.4
MAINTAINER brennolncosta@gmail.com

ARG BUILD_CORES=1

RUN apk add --update \
      autoconf \
      automake \
      build-base\
      curl \
      git \
      libtool \
      qt5-qtbase-dev

# Build protobuf against configured revision
#
ENV PROTOBUF_REVISION v3.1.0
RUN git clone https://github.com/google/protobuf -b $PROTOBUF_REVISION --depth 1 \
  && cd protobuf \
  && ./autogen.sh \
  && ./configure --prefix=/usr \
  && make -j $BUILD_CORES \
  && make check \
  && make install \
  && cd .. && rm -rf protobuf && cd

# Build [protoc-gen-doc](https://github.com/estan/protoc-gen-doc) against configured revision
#
# protobuf plugin to generate docs in markdown, html, docbook and pdf
#
ENV PROTOC_GEN_DOC_REVISION 225664a903cebe0823669bdc5ea97ea9cbd80989
RUN git clone https://github.com/estan/protoc-gen-doc.git \
  && cd protoc-gen-doc \
  && git checkout $PROTOC_GEN_DOC_REVISION \
  && /usr/lib/qt5/bin/qmake \
  && make \
  && cp protoc-gen-doc /usr/local/bin \
  && cd .. && rm -rf protoc-gen-doc && cd

# Build [ScalaPB](https://github.com/trueaccord/ScalaPB) plugin
#
# This plugin make possible to generate Scala's case class for a given proto.
#
# Important: Java is a dependency!
#
ENV SCALA_PB_VERSION 0.5.47
RUN curl -sLO "https://github.com/trueaccord/ScalaPB/releases/download/v$SCALA_PB_VERSION/scalapbc-$SCALA_PB_VERSION.zip" \
  && unzip "scalapbc-$SCALA_PB_VERSION.zip" \
  && mv "scalapbc-$SCALA_PB_VERSION" /usr/local/lib/scalapbc \
  && ln -s /usr/local/lib/scalapbc/bin/scalapbc /usr/local/bin/scalapbc

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
    JAVA_UPDATE=112 \
    JAVA_BUILD=15 \
    JAVA_HOME="/opt/jdk"

RUN apk add --no-cache --virtual=java-dependencies ca-certificates \
    && cd "/tmp" \
    && curl -sL --header "Cookie: oraclelicense=accept-securebackup-cookie;" -O "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" \
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

# Needed shared libraries and tools by protobuf and their plugins
RUN apk --update add \
  bash \
  libstdc++ \
  qt5-qtbase

# Cleaning up
RUN apk del \
  autoconf \
  automake \
  build-base \
  curl \
  git \
  libtool \
  qt5-qtbase-dev \
  && rm -rf /var/cache/apk/*

