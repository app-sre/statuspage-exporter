package config

import (
	"flag"
	"os"
)

type Args struct {
	Token  string
	PageId string
	Port   string
}

func Parse() *Args {
	var args Args

	args.Token = os.Getenv("TOKEN")

	flag.StringVar(&args.PageId, "page-id", "", "Page ID used for statuspage")
	flag.StringVar(&args.Port, "port", "9115", "Port used for metrics server")

	flag.Parse()

	return &args
}
