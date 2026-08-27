FROM registry.access.redhat.com/ubi9/go-toolset:1.26.7-1787774815@sha256:1a755651ffe1a438f137418d183f18ebad527ec929206c17804f93490a97869e as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.8-1787647261@sha256:580752f96d36c4132bffd30f9c34865bf4bd87f6aa161c969d117f21732e50f7
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
