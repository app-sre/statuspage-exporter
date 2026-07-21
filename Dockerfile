FROM registry.access.redhat.com/ubi9/go-toolset:1.26.5-1784638038@sha256:981cd8d53cc230b928db75a697586f915da5d3ed6731eddb246ce8865e0b1400 as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.8-1784596070@sha256:6c79f4fb38a20d496c859025d57e4074835e849d5d14819c4e021ad78446bce8
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
