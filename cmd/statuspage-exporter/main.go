package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/app-sre/statuspage-exporter/pkg/collectors"
	"github.com/app-sre/statuspage-exporter/pkg/config"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func main() {
	reg := prometheus.NewRegistry()
	// reg.MustRegister(.NewComponentCollector())
	reg.MustRegister(collectors.NewComponentCollector(config.Parse()))

	fmt.Println("Now serving metrics at http://localhost:9101/metrics")
	http.Handle("/metrics", promhttp.HandlerFor(reg, promhttp.HandlerOpts{}))
	log.Fatal(http.ListenAndServe(":9101", nil))
}
