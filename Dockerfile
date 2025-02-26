FROM registry.access.redhat.com/ubi9/go-toolset:9.5-1739801907@sha256:703937e152d049e62f5aa8ab274a4253468ab70f7b790d92714b37cf0a140555 as builder
COPY LICENSE /licenses/LICENSE
WORKDIR /build
RUN git config --global --add safe.directory /build
COPY . .
RUN make build

FROM builder as test
RUN make test

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.5-1736404155
COPY --from=builder /build/statuspage-exporter  /bin/statuspage-exporter
EXPOSE 9101
ENTRYPOINT [ "/bin/statuspage-exporter" ]
