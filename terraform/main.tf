terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "hello" {
  name = "hello-world:latest"
}

resource "docker_container" "hello" {
  name      = "hello-world-terraform"
  image     = docker_image.hello.name
  attach    = false
  must_run  = false
}