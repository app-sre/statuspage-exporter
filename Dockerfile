FROM registry.access.redhat.com/ubi9/go-toolset:1.26.3-1781757851@sha256:b2c0898987b688a95f4d2f38abdfd929f45903948831783153019ab749495c72 as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.8-1782191395@sha256:850143255ee0d1915f09aaa09f6ed31f24086ba605c323badfbefa95b8c52b0e
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
