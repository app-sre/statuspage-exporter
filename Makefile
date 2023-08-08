build:
	go build -o status-page-exporter/main main.go 

containerize: build
	podman build -f status-page-exporter/Containerfile -t status-page-exporter

kube: build
	podman kube down exporter.yaml || true
	podman kube play exporter.yaml --build=true

clean:
	rm -f main status-page-exporter/main

.PHONY: clean
