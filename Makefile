FIXTURES=fixtures/today.proto
TAG?=$(shell git rev-parse --short HEAD)

protobuf-tools = @docker run --rm -v `pwd`:/proto-sources:ro -w /proto-sources brennovich/protobuf-tools:$(TAG)

test/python:
	@echo "Building for python..."
	$(protobuf-tools) protoc --python_out=/tmp ${FIXTURES}

test/java:
	@echo "Building for java..."
	$(protobuf-tools) protoc --java_out=/tmp ${FIXTURES}

test/go:
	@echo "Building for go..."
	$(protobuf-tools) protowrap -I . --go_out=/tmp ./${FIXTURES}

test/scala:
	@echo "Building for scala..."
	$(protobuf-tools) scalapbc --scala_out=flat_package:/tmp --proto_path /usr/local/include --proto_path fixtures ${FIXTURES}

test/js:
	@echo "Building for javascript..."
	$(protobuf-tools) protoc --js_out=/tmp ${FIXTURES}

test/index.html: ${FIXTURES}
	@echo "Creating docs..."
	$(protobuf-tools) protoc --doc_out=html,index.html:/tmp ${FIXTURES}

test: docker/build test/go test/java test/scala test/python test/js test/index.html

docker/build:
	docker build --tag brennovich/protobuf-tools:$(TAG) .

docker/release: docker/build
	git tag v$(RELEASE) && git push --tags
	docker tag brennovich/protobuf-tools:$(TAG) brennovich/protobuf-tools:latest
	docker tag brennovich/protobuf-tools:$(TAG) brennovich/protobuf-tools:$(RELEASE)
	docker push brennovich/protobuf-tools:$(RELEASE)
	docker push brennovich/protobuf-tools:latest
