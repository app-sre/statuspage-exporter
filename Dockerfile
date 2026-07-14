FROM registry.access.redhat.com/ubi9/go-toolset:1.26.5-1784032128@sha256:b471d69d4bf8a0aeac420f0e38777b1e38a59f7e805cba3e1c03d0066a1961af as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.8-1782797275@sha256:463cae32c6f6f5594b11a5c22de275016bd8545ce58a6373388e8b24f13fc15c
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
