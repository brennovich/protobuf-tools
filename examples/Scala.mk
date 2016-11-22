project_name = EXAMPLE
project_dir = $(shell pwd)
user = $(shell id -u $(USER))
group = $(shell id -g $(USER))

protoc_cmd = docker run \
	     -v $(project_dir):/$(project_name) \
	     -w /$(project_name) -u $(user):$(group) \
	     --rm brennovich/protobuf-tools:latest

proto_version = v0.3.0
protos_path = tmp/RESOURCES_PROJECT_NAME
resources_path = src/main/generated-proto

build_resources: build_resources/clean
	- mkdir -p $(protos_path) $(resources_path)
	- git clone \
		--branch $(proto_version) \
		--depth 1 GIT_PROJECT_URL \
		$(protos_path) &> /dev/null
	- find "./$(protos_path)" -name "*.proto" \
		| xargs $(protoc_cmd) scalapbc --proto_path=./$(protos_path) \
		--scala_out=flat_package:./$(resources_path)

build_resources/clean:
	- rm -rf $(protos_path) $(resources_path)
