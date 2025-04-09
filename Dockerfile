FROM registry.access.redhat.com/ubi9/go-toolset:1.22.9-1744194661@sha256:e4193e71ea9f2e2504f6b4ee93cadef0fe5d7b37bba57484f4d4229801a7c063 as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.5-1742914212@sha256:ac61c96b93894b9169221e87718733354dd3765dd4a62b275893c7ff0d876869
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
