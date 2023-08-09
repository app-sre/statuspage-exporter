package config

import (
	"flag"
	"os"
	"time"
)

type CollectorOpts struct {
	Token           string
	PageId          string
	Port            string
	ScraperInterval time.Duration
	ScraperTimeout  time.Duration
}

func Parse() *CollectorOpts {
	var args CollectorOpts

	args.Token = os.Getenv("TOKEN")

	flag.StringVar(&args.PageId, "page-id", "", "Page ID used for statuspage")
	flag.StringVar(&args.Port, "port", "9115", "Port used for metrics server")
	flag.DurationVar(&args.ScraperTimeout, "scraper-timeout", 4*time.Second, "Timeout for scraper http calls")
	flag.DurationVar(&args.ScraperInterval, "scraper-interval", 5*time.Second, "Interval for scraping metrics")

	flag.Parse()

	return &args
}
