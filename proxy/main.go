package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"
)

type ServiceStatus struct {
	Jenkins  string `json:"jenkins"`
}

type Status struct {
	Server ServiceStatus `json:"server"`
}

func checkJenkinsHealth() string {
	client := &http.Client{Timeout: 5 * time.Second}
	resp, err := client.Get("http://jenkins_server:8080/login")
	if err != nil {
		return "down"
	}
	defer resp.Body.Close()
	if resp.StatusCode == http.StatusOK || resp.StatusCode == http.StatusUnauthorized {
		return "up"
	}
	return "down"
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Welcome to the home lab."})
}


func statusHandler(w http.ResponseWriter, r *http.Request) {
	status := Status{
		Server: ServiceStatus{
			Jenkins:  checkJenkinsHealth(),
		},
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(status)
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8085"
	}
	// homee
	http.HandleFunc("/", homeHandler)

	// status
	http.HandleFunc("/status", statusHandler)

	log.Printf("Health proxy listening on :%s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}