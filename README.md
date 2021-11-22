# Protobuf Tools

A docker image with protobuf and a handful set of plugins.

[![](https://images.microbadger.com/badges/version/vivareal/protobuf-tools.svg)](https://microbadger.com/images/vivareal/protobuf-tools "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/vivareal/protobuf-tools.svg)](https://microbadger.com/images/vivareal/protobuf-tools "Get your own image badge on microbadger.com")

## Motivation

The whole idea is to provide an easy-almost-no-setup way to generate resources and documentation
from `protos`.

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
  -v ${PWD}:/my-protos:ro \
  -w /my-protos \
  --rm -it vivareal/protobuf-tools:latest protoc --doc_out=html,index.html:/build *.proto

# Make sure to use docker cp instead of writing in the mounted folder, it avoids permissions issues and is much more flexible
docker cp my-protos:/build compiled-protos
docker rm my-protos
```

For more examples compiling for various languages look `[Makefile]

## Test & build

All of that can be done using makefile:

```
make test # this will build a Docker image of current HEAD and run plugins and extensions
make docker-build # build the docker image locally.
```

Check out `[Makefile]` for more tasks ;)

## Contributing

1. Fork it
2. Fix, or add your feature in a new branch
3. Open up a Pull Request against this repo with a useful description
4. Try to stick with formatting conventions already used in the files

## Deploying

First, check the latest generated versions [here](https://github.com/olxbr/protobuf-tools/releases).

After your pull request is merged, you can generate a new version by running the `release` workflow dispatch in [GitHub Actions](https://github.com/olxbr/protobuf-tools/actions/workflows/release.yaml) (just click "Run workflow" and fill it with the new version to be released - please use [semantic versioning](https://semver.org/)). That workflow will then generate the given release in GitHub and push a Docker image with the same tag.
