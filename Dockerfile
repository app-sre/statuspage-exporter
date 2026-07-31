FROM registry.access.redhat.com/ubi9/go-toolset:1.26.5-1785443561@sha256:0b0dd6f4ee311854a6b8e18b3bc52e7aa6b66f935a16c8f9bda173353ab16c64 as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.8-1785339117@sha256:17fd831ced9434de0a984d60b3fbe61008308261ba98bbc348d6fbdef05fa7c0
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
