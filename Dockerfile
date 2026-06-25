FROM registry.access.redhat.com/ubi9/go-toolset:1.26.3-1782348382@sha256:6fdc004bff119315ee4f19363ac1dec934fc40270d9aa1e6b4fbfa2467757570 as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.8-1782366411@sha256:44bc70ef6e6ea9a70e353be97f4722e10358d09fbb9494ca943b2a641049690e
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
