package collectors

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/app-sre/statuspage-exporter/pkg/api"
	"github.com/app-sre/statuspage-exporter/pkg/config"
	"github.com/prometheus/client_golang/prometheus"
)

type ComponentCollector struct {
	Status        *prometheus.Desc
	StatusMetrics []prometheus.Metric

	Operational        *prometheus.Desc
	OperationalMetrics []prometheus.Metric

	APIErrorCount       *prometheus.Desc
	APIErrorCountMetric float64

	APIRequestCount       *prometheus.Desc
	APIRequestCountMetric float64

	Args  *config.Args
	mutex *sync.Mutex
}

func NewComponentCollector(args *config.Args) *ComponentCollector {

	cc := &ComponentCollector{
		Args:            args,
		Status:          prometheus.NewDesc(prometheus.BuildFQName("component", "", "status"), "Status", []string{"name", "group", "id", "group_id", "status"}, nil),
		Operational:     prometheus.NewDesc(prometheus.BuildFQName("component", "", "operational"), "Operational", []string{"name", "group", "id", "group_id"}, nil),
		APIErrorCount:   prometheus.NewDesc(prometheus.BuildFQName("component", "", "error_count"), "Error Count", []string{}, nil),
		APIRequestCount: prometheus.NewDesc(prometheus.BuildFQName("component", "", "request_count"), "Request Count", []string{}, nil),
		mutex:           &sync.Mutex{},
	}

	go cc.ScrapeLoop()

	return cc
}

func (cc *ComponentCollector) Describe(ch chan<- *prometheus.Desc) {
	ch <- cc.Status
}

func (cc *ComponentCollector) Collect(ch chan<- prometheus.Metric) {
	cc.mutex.Lock()
	defer cc.mutex.Unlock()

	ch <- prometheus.MustNewConstMetric(cc.APIErrorCount, prometheus.GaugeValue, cc.APIErrorCountMetric)
	ch <- prometheus.MustNewConstMetric(cc.APIRequestCount, prometheus.GaugeValue, cc.APIRequestCountMetric)

	for _, v := range cc.StatusMetrics {
		ch <- v
	}

	for _, v := range cc.OperationalMetrics {
		ch <- v
	}
}

func (cc *ComponentCollector) IncrementRequests() {
	cc.mutex.Lock()
	defer cc.mutex.Unlock()

	cc.APIRequestCountMetric++
}

func (cc *ComponentCollector) IncrementErrors() {
	cc.mutex.Lock()
	defer cc.mutex.Unlock()

	cc.APIErrorCountMetric++
}

func statusPageAPI(url string, token string) ([]byte, error) {
	client := &http.Client{}

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}

	req.Header.Add("Authorization", fmt.Sprintf("OAuth %s", token))

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}

	return io.ReadAll(resp.Body)
}

func (cc *ComponentCollector) getGroups() (map[string]string, error) {
	url := fmt.Sprintf("https://api.statuspage.io/v1/pages/%s/components?page=1&per_page=500", cc.Args.PageId)

	body, err := statusPageAPI(url, cc.Args.Token)
	if err != nil {
		cc.IncrementErrors()
		return nil, err
	}

	var compGroups api.ComponentGroups
	err = json.Unmarshal(body, &compGroups)
	if err != nil {
		cc.IncrementErrors()
		return nil, err
	}

	groups := make(map[string]string)
	for _, cg := range compGroups {
		if cg.GroupID == "" {
			continue
		}
		groups[cg.GroupID] = cg.Name
	}

	return groups, nil
}

func (cc *ComponentCollector) getComponents() (api.Components, error) {
	// TODO: Figure out values for pagination
	url := fmt.Sprintf("https://api.statuspage.io/v1/pages/%s/components?page=1&per_page=500", cc.Args.PageId)

	body, err := statusPageAPI(url, cc.Args.Token)
	if err != nil {
		cc.IncrementErrors()
		return nil, err
	}

	var comps api.Components
	err = json.Unmarshal(body, &comps)
	if err != nil {
		cc.IncrementErrors()
		return nil, err
	}

	return comps, nil
}

func (cc *ComponentCollector) ScrapeLoop() {
	for {
		select {
		// TODO: Make this an arg
		case <-time.After(5 * time.Second):

			groups, err := cc.getGroups()
			if err != nil {
				cc.IncrementErrors()
				log.Println(err)
				continue
			}

			components, err := cc.getComponents()
			if err != nil {
				cc.IncrementErrors()
				log.Println(err)
				continue
			}

			cc.IncrementRequests()

			cc.mutex.Lock()

			// Clear out metrics each iteration
			cc.StatusMetrics = make([]prometheus.Metric, len(components))
			cc.OperationalMetrics = make([]prometheus.Metric, len(components))

			for i, c := range components {
				group := ""
				if c.GroupId != "" {
					group = groups[c.GroupId]
				}

				cc.StatusMetrics[i] = prometheus.MustNewConstMetric(cc.Status, prometheus.GaugeValue, 1, c.Name, group, c.Id, c.GroupId, c.Status)
				if c.Status == "operational" {
					cc.OperationalMetrics[i] = prometheus.MustNewConstMetric(cc.Operational, prometheus.GaugeValue, 1, c.Name, group, c.Id, c.GroupId)
				} else {
					cc.OperationalMetrics[i] = prometheus.MustNewConstMetric(cc.Operational, prometheus.GaugeValue, 0, c.Name, group, c.Id, c.GroupId)
				}
			}

			cc.mutex.Unlock()
		}
	}
}
