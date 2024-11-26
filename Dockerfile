ARG EXPORTER_VER=0.2.4

FROM --platform=$BUILDPLATFORM golang:alpine AS build
ARG TARGETOS TARGETARCH

WORKDIR /build

#ADD go.mod go.sum ./

ARG EXPORTER_VER
ADD . ./
RUN GOOS=$TARGETOS go install github.com/frebib/enumerx@latest
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go mod download

RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go generate
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build \
        -v \
        -trimpath \
        -ldflags="-w -s -X 'main.Version=$EXPORTER_VER'" \
        -o /nzbget_exporter

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FROM spritsail/alpine:3.19

ARG EXPORTER_VER

LABEL org.opencontainers.image.authors="dis" \
      org.opencontainers.image.title="nzbget-exporter" \
      org.opencontainers.image.url="https://github.com/disconn3ct/nzbget-exporter" \
      org.opencontainers.image.description="NZBGet Prometheus metrics exporter" \
      org.opencontainers.image.version=${EXPORTER_VER}

COPY --from=build /nzbget_exporter /usr/bin
CMD ["/usr/bin/nzbget_exporter"]
