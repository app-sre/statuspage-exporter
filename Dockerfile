FROM registry.access.redhat.com/ubi9/go-toolset:1.25.8-1776084839@sha256:7a0aad98db45c0aac69813bb9b5af20018bd51f47a2fc183aeca89d6a05c046e as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.7-1776104705@sha256:fe688da81a696387ca53a4c19231e99289591f990c904ef913c51b6e87d4e4df
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
