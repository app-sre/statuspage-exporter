FROM registry.access.redhat.com/ubi9/go-toolset:1.26.3-1781757851@sha256:b2c0898987b688a95f4d2f38abdfd929f45903948831783153019ab749495c72 as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.8-1781496742@sha256:1bc3c5c15720506a0cf48adfdf8b623dfe704377e007d7bbae8d14876392ca6a
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
