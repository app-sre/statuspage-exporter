FROM registry.access.redhat.com/ubi9/go-toolset:1.25.9-1778504036@sha256:2c17ce45c735ad308240139d807eeb22f4499fd90e883634ba5a191779f1ff94 as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.7-1778461551@sha256:fe9e574f04371b333ed4e21d30d984f6b7fcd1046e579f5ddab4816c0c8e231d
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
