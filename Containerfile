FROM registry.access.redhat.com/ubi9/go-toolset

COPY ./statuspage-exporter .

ARG PAGE_ID
ARG TOKEN

EXPOSE 9101

ENTRYPOINT [ "/usr/bin/sh" ]

CMD [ "-c", "./statuspage-exporter" ]
