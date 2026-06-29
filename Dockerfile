FROM registry.access.redhat.com/ubi9/go-toolset:1.26.4-1782717933@sha256:8d2d83261cbc8854b8c93b1237d7d4aa0069bdb93e2974d980bc7788db56f8f4 as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.8-1782708562@sha256:c5478a52c410e71c53839923c83a1480199a1e74ce5736fe3e3a5578dc399102
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
