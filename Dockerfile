FROM golang:1.21-bullseye AS builder
WORKDIR /tmp/src
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .
ARG VERSION=unknown
RUN  GOARCH=amd64 GOOS=linux CGO_ENABLED=1  go build -mod=readonly -ldflags "-X main.version=$VERSION" -o codexray-cluster-agent .


FROM registry.access.redhat.com/ubi9/ubi

ARG VERSION=unknown
LABEL name="codexray-cluster-agent" \
      vendor="Codexray, Inc." \
      version=${VERSION} \
      summary="Codexray Cluster Agent."

COPY LICENSE /licenses/LICENSE

COPY --from=builder /tmp/src/codexray-cluster-agent /usr/bin/codexray-cluster-agent
RUN mkdir /data && chown 65534:65534 /data

USER 65534:65534
VOLUME /data
ENTRYPOINT ["codexray-cluster-agent"]
