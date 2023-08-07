package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
)

func handleError(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

func main() {
	pageId := os.Getenv("PAGE_ID")
	token := os.Getenv("TOKEN")

	url := fmt.Sprintf("https://api.statuspage.io/v1/pages/%s/components", pageId)

	client := &http.Client{}

	req, err := http.NewRequest("GET", url, nil)
	handleError(err)

	req.Header.Add("Authorization", fmt.Sprintf("OAuth %s", token))

	resp, err := client.Do(req)
	handleError(err)

	body, err := io.ReadAll(resp.Body)
	handleError(err)

	fmt.Println(string(body))
}
