FROM registry.access.redhat.com/ubi9/go-toolset:1.26.5-1784090680@sha256:e1ff4f548dfca084c2318d11dccd7d30a75c81a3a4fd8abcebc42ea42dd683e8 as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.8-1784092902@sha256:062c52ff973065752b0965787649db2bcf551a6c727a00e95a3eb42cebadbdab
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
