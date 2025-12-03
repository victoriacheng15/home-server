package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

type Status struct {
	Server string `json:"server"`
}

func statusHandler(w http.ResponseWriter, r *http.Request) {
	status := Status{Server: "up"}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(status)
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8085"
	}
	http.HandleFunc("/status", statusHandler)
	log.Printf("Health proxy listening on :%s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}