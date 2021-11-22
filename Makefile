FIXTURES=fixtures/today.proto
TAG?=$(shell git rev-parse --short HEAD)
VENDOR=vivareal

protobuf-tools = @docker run --rm -v ${PWD}:/proto-sources:ro -w /proto-sources ${VENDOR}/protobuf-tools:$(TAG)

.PHONY: docker-build docker-push test test-go test-java test-scala test-python test-js test-index.html

test-python:
	@echo "Building for python..."
	$(protobuf-tools) protoc --python_out=/tmp ${FIXTURES}

test-java:
	@echo "Building for java..."
	$(protobuf-tools) protoc --java_out=/tmp ${FIXTURES}

test-go:
	@echo "Building for go..."
	$(protobuf-tools) protowrap -I . --go_out=/tmp ./${FIXTURES}

test-scala:
	@echo "Building for scala..."
	$(protobuf-tools) scalapbc --scala_out=flat_package:/tmp --proto_path /usr/local/include --proto_path fixtures ${FIXTURES}

test-js:
	@echo "Building for javascript..."
	$(protobuf-tools) protoc --js_out=/tmp ${FIXTURES}

test-index.html: ${FIXTURES}
	@echo "Creating docs..."
	$(protobuf-tools) protoc --doc_out=html,index.html:/tmp ${FIXTURES}

test: docker-build test-go test-java test-scala test-python test-js test-index.html

docker-build:
	docker build --tag ${VENDOR}/protobuf-tools:$(TAG) .

docker-push: docker-build
	docker tag ${VENDOR}/protobuf-tools:$(TAG) ${VENDOR}/protobuf-tools
	docker push ${VENDOR}/protobuf-tools:$(TAG)
	docker push ${VENDOR}/protobuf-tools

release:
	RELEASE_MESSAGE=`scripts/release_message.sh` make release/post

release/post:
	@echo "\nWill create release $(TAG)"
	@echo "Release changelog will be:\n$(RELEASE_MESSAGE)"
	curl -sLfS -H "Authorization: token $(GH_TOKEN)" https://api.github.com/repos/olxbr/protobuf-tools/releases \
		-d '{ "tag_name": "$(TAG)", "target_commitish": "master", "name": "$(TAG)", "body": "$(RELEASE_MESSAGE)", "draft": false, "prerelease": false }' > /dev/null
	- @echo "Done. You can now check the progress here: https://github.com/olxbr/protobuf-tools/actions"
