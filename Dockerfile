FROM registry.access.redhat.com/ubi9/go-toolset:1.25.8-1775437082@sha256:469da742918d6916d441952dd53a760aa2cb5397d672c9143b0dcfa01f9efe91 as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.7-1773939694@sha256:83006d535923fcf1345067873524a3980316f51794f01d8655be55d6e9387183
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
