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
ENV PROTOBUF_REVISION v3.0.2
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

RUN apk del \
  autoconf \
  automake \
  build-base \
  curl \
  git \
  libtool \
  qt5-qtbase-dev \
  && rm -rf /var/cache/apk/*

# Needed shared libraries by protobuf and their plugins
RUN apk --update add \
  libstdc++ \
  qt5-qtbase
