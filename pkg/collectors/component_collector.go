package collectors

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"sync"

	"github.com/app-sre/statuspage-exporter/pkg/api"
	"github.com/prometheus/client_golang/prometheus"
)

// TODO: INcrement error metric https://github.com/app-sre/aws-resource-exporter/blob/master/pkg/awsclient/exporter.go#L64
func handleError(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

type ComponentCollector struct {
	Status      *prometheus.Desc
	Operational *prometheus.Desc
	mutex       *sync.Mutex
}

func NewComponentCollector() *ComponentCollector {
	return &ComponentCollector{
		Status:      prometheus.NewDesc(prometheus.BuildFQName("component", "", "status"), "Status", []string{"name", "group", "id", "group_id", "status"}, nil),
		Operational: prometheus.NewDesc(prometheus.BuildFQName("component", "", "operational"), "Status", []string{"name", "group", "id", "group_id"}, nil),
		mutex:       &sync.Mutex{},
	}
}

func (cc *ComponentCollector) Describe(ch chan<- *prometheus.Desc) {
	ch <- cc.Status
}

func (cc *ComponentCollector) Collect(ch chan<- prometheus.Metric) {
	groups, err := getGroups()
	handleError(err)

	components, err := getComponents()
	handleError(err)

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

func statusPageAPI(url string) ([]byte, error) {
	token := os.Getenv("TOKEN")

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

func getGroups() (map[string]string, error) {
	pageId := os.Getenv("PAGE_ID")
	url := fmt.Sprintf("https://api.statuspage.io/v1/pages/%s/components?page=1&per_page=500", pageId)

	body, err := statusPageAPI(url)
	if err != nil {
		return nil, err
	}

	// var compGroups api.ComponentGroups
	var compGroups api.ComponentGroups
	err = json.Unmarshal(body, &compGroups)
	if err != nil {
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

func getComponents() (api.Components, error) {
	pageId := os.Getenv("PAGE_ID")

	// TODO: Figure out values for pagination
	url := fmt.Sprintf("https://api.statuspage.io/v1/pages/%s/components?page=1&per_page=500", pageId)

	body, err := statusPageAPI(url)
	if err != nil {
		return nil, err
	}

	var comps api.Components
	err = json.Unmarshal(body, &comps)
	if err != nil {
		handleError(err)
	}

	return comps, nil
}
