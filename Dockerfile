FROM registry.access.redhat.com/ubi9/go-toolset:1.26.7-1787774815@sha256:1a755651ffe1a438f137418d183f18ebad527ec929206c17804f93490a97869e as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.8-1788166357@sha256:7fbeae18dc9476399f565e68255f602a3374ea8614ba3d14843565131a13ff93
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
