FROM registry.redhat.io/ubi9/go-toolset:1.22.5-1731639025 as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.redhat.io/ubi9/ubi-minimal@sha256:8b6978d555746877c73f52375f60fd7b6fd27d6aca000eaed27d0995303c13de
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
