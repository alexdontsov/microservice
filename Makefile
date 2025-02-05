include .env

LOCAL_BIN:=$(CURDIR)/bin

install-golangci-lint:
	GOBIN=$(LOCAL_BIN) go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.61.0

lint:
	$(LOCAL_BIN)/golangci-lint run ./... --config .golangci.pipeline.yaml

install-deps:
	GOBIN=$(LOCAL_BIN) go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28.1
	GOBIN=$(LOCAL_BIN) go install -mod=mod google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2

get-deps:
	go get -u google.golang.org/protobuf/cmd/protoc-gen-go
	go get -u google.golang.org/grpc/cmd/protoc-gen-go-grpc

generate:
	make generate-user-api

build:
	GOOS=linux GOARCH=amd64 go build -o service_linux cmd/main.go

go-to-server:
	scp service_linux ${SERVER_USER}@${SERVER_HOST}:

docker-build-and-push:
	docker buildx build --no-cache --platform linux/amd64 -t ${REGISTRY_URL}/test-server:v0.0.1 .
	docker login -u ${REGISTRY_USERNAME} -p ${REGISTRY_TOKEN} ${REGISTRY_URL}
	docker push ${REGISTRY_URL}/test-server:v0.0.1

generate-user-api:
	mkdir -p pkg/user/v1
	protoc --proto_path api/user/v1 \
	--go_out=pkg/user/v1 --go_opt=paths=source_relative \
	--plugin=protoc-gen-go=bin/protoc-gen-go \
	--go-grpc_out=pkg/user/v1 --go-grpc_opt=paths=source_relative \
	--plugin=protoc-gen-go-grpc=bin/protoc-gen-go-grpc \
	api/user/v1/user.proto
