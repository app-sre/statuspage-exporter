FROM registry.access.redhat.com/ubi9/go-toolset:1.26.5-1787559109@sha256:643754d95cf8907b109b3e9182932e9c6e05334c97a74bb5cd991617e3d03080 as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.8-1786987521@sha256:8eb2830d0936237fc13a1f2f7e45aecf90d69043380ad167fad0343632937f41
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
