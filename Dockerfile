FROM golang:1.23.5-alpine AS builder

COPY . /service/
WORKDIR /service/

RUN go mod download
RUN go build -o ./bin/server cmd/main.go

FROM alpine:latest

WORKDIR /root/
COPY --from=builder /service .

CMD ["./bin/server"]