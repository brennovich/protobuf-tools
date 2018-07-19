# Protobuf Tools

A docker image with protobuf and a handful set of plugins.

[![](https://images.microbadger.com/badges/image/brennovich/protobuf-tools.svg)](https://microbadger.com/images/brennovich/protobuf-tools "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/brennovich/protobuf-tools.svg)](https://microbadger.com/images/brennovich/protobuf-tools "Get your own version badge on microbadger.com")

## Motivation

The whole idea is to provide an easy-almost-no-setup way to generate resources and documentation
from `proto`s.

## Dependencies

- Docker

## Content

This image gives you a compiled protobuf and some of its plugins (not so many for now):

- `protobuf3`: https://github.com/google/protobuf
- `protoc-gen-doc`: https://github.com/pseudomuto/protoc-gen-doc
- `protoc-gen-scala`: https://github.com/scalapb/ScalaPB
- `protoc-gen-go`: https://github.com/golang/protobuf
- `goprotowrap`: https://github.com/square/goprotowrap
- `rust-protobuf`: https://github.com/stepancheg/rust-protobuf

## Usage

`docker run` with a couple options:

```sh
# Here we're inside your proto's folder, let's call it `my-protos`
cd ~/my-protos

docker run \
  --name my-protos
  -v `pwd`:/my-protos:ro \
  -w /my-protos \
  --rm -it brennovich/protobuf-tools:latest protoc --doc_out=html,index.html:/build *.proto

# Make sure to use docker cp instead of writing in mounted folder, it avoid permissions issues and is much more flexible
docker cp my-protos:/build compiled-protos
docker rm my-protos
```

For more examples compiling for various languages look `[Makefile]

## Test, buid & release

All of that can be done using makefile:

```
make test # this will build a docker image of current HEAD and run plugins and extensions
make release RELEASE=3.0.0 # build a docker iamge, tag and publish it to brennovich/protobuf-tools docker hub repo
```

Checkout `[Makefile]` for more tasks ;)

## Contributing

1. Fork it
2. Fix, or add your feature in a new branch
3. Open up a Pull Request against this repo with an useful description
4. Try to stick with formating conventions already used in the files
