package collectors

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"sync"

	"github.com/app-sre/statuspage-exporter/pkg/api"
	"github.com/app-sre/statuspage-exporter/pkg/config"
	"github.com/prometheus/client_golang/prometheus"
)

type ComponentCollector struct {
	Args            *config.Args
	Status          *prometheus.Desc
	Operational     *prometheus.Desc
	APIErrorCount   int64
	APIRequestCount int64
	mutex           *sync.Mutex
}

func NewComponentCollector(args *config.Args) *ComponentCollector {
	return &ComponentCollector{
		Args:        args,
		Status:      prometheus.NewDesc(prometheus.BuildFQName("component", "", "status"), "Status", []string{"name", "group", "id", "group_id", "status"}, nil),
		Operational: prometheus.NewDesc(prometheus.BuildFQName("component", "", "operational"), "Status", []string{"name", "group", "id", "group_id"}, nil),
		mutex:       &sync.Mutex{},
	}
}

func (cc *ComponentCollector) Describe(ch chan<- *prometheus.Desc) {
	ch <- cc.Status
}

func (cc *ComponentCollector) Collect(ch chan<- prometheus.Metric) {
	groups, err := cc.getGroups()
	if err != nil {
		cc.IncrementErrors()
		log.Println(err)
	}

	components, err := cc.getComponents()
	if err != nil {
		cc.IncrementErrors()
		log.Println(err)
	}

	for _, c := range components {
		group := ""
		if c.GroupId != "" {
			group = groups[c.GroupId]
		}

		ch <- prometheus.MustNewConstMetric(cc.Status, prometheus.GaugeValue, 1, c.Name, group, c.Id, c.GroupId, c.Status)

		if c.Status == "operational" {
			ch <- prometheus.MustNewConstMetric(cc.Operational, prometheus.GaugeValue, 1, c.Name, group, c.Id, c.GroupId)
		} else {
			ch <- prometheus.MustNewConstMetric(cc.Operational, prometheus.GaugeValue, 0, c.Name, group, c.Id, c.GroupId)
		}
	}
}

func (cc *ComponentCollector) IncrementRequests() {
	cc.mutex.Lock()
	defer cc.mutex.Unlock()

	cc.APIRequestCount++
}

func (cc *ComponentCollector) IncrementErrors() {
	cc.mutex.Lock()
	defer cc.mutex.Unlock()

	cc.APIErrorCount++
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

	// var compGroups api.ComponentGroups
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
		log.Println(err)
		return nil, err
	}

	return comps, nil
}
