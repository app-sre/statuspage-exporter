FROM registry.access.redhat.com/ubi9/go-toolset:1.26.5-1785156757@sha256:5e231f8c5eab7812a1e2c701ce48c63eb3bb02dc9f372d8fbb59e3e1cd9c493c as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.8-1785214301@sha256:2a98ec380ad75004992b8538380a5003da64442f0a69237ed236859e023c71d0
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
