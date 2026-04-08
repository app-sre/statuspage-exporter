FROM registry.access.redhat.com/ubi9/go-toolset:1.25.8-1775651161@sha256:d62320532419e2cb02a2ed6a3af5dd82a1e5e0b7ae3ba8a5b84fc2236be5d913 as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.7-1775623882@sha256:d91be7cea9f03a757d69ad7fcdfcd7849dba820110e7980d5e2a1f46ed06ea3b
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
