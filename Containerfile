FROM registry.access.redhat.com/ubi9/go-toolset

COPY ./statuspage-exporter /bin

ARG PAGE_ID
ARG TOKEN

EXPOSE 9101

ENTRYPOINT [ "/bin/statuspage-exporter" ]
