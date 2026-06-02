terraform {
  backend "local" {
    path = "/home/quidz/terraform-safe-state/terraform.tfstate"
  }
  
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "nginx" {
}

resource "docker_container" "portfolio_web" {
}

# --- MONITORING & OBSERVABILITY ---

# Mengunduh Image Monitoring
resource "docker_image" "cadvisor" {
  name         = "gcr.io/cadvisor/cadvisor:v0.47.0"
  keep_locally = false
}
resource "docker_image" "prometheus" {
  name         = "prom/prometheus:latest"
  keep_locally = false
}
resource "docker_image" "grafana" {
  name         = "grafana/grafana:latest"
  keep_locally = false
}

# Container 1: cAdvisor (Port 8081)
resource "docker_container" "cadvisor" {
  image = docker_image.cadvisor.image_id
  name  = "portfolio-cadvisor"
  privileged = true
  restart = "always"
  ports {
    internal = 8080
    external = 8081
  }
  
  # Volume khusus agar cAdvisor bisa membaca mesin Docker (Diubah ke format multi-line)
  volumes {
    host_path      = "/"
    container_path = "/rootfs"
    read_only      = true
  }
  volumes {
    host_path      = "/var/run"
    container_path = "/var/run"
    read_only      = true
  }
  volumes {
    host_path      = "/sys"
    container_path = "/sys"
    read_only      = true
  }
  volumes {
    host_path      = "/var/lib/docker/"
    container_path = "/var/lib/docker/"
    read_only      = true
  }
}

# Container 2: Prometheus (Port 9090)
resource "docker_container" "prometheus" {
  image = docker_image.prometheus.image_id
  name  = "portfolio-prometheus"
  restart = "always"
  ports {
    internal = 9090
    external = 9090
  }
  volumes {
    # Menyuntikkan file konfigurasi yang kita buat di Langkah 1
    host_path      = abspath("../monitoring/prometheus.yml")
    container_path = "/etc/prometheus/prometheus.yml"
    read_only      = true
  }
}

# Container 3: Grafana (Port 3000)
resource "docker_container" "grafana" {
  image = docker_image.grafana.image_id
  name  = "portfolio-grafana"
  restart = "always"
  ports {
    internal = 3000
    external = 3000
  }
}

resource "docker_image" "postgres" {
  name         = "postgres:15-alpine"
  keep_locally = true
}

resource "docker_container" "portfolio_db" {
  name    = "portfolio-database-satelit"
  image   = docker_image.postgres.image_id
  restart = "always"
  
  # Konfigurasi kredensial database
  env = [
    "POSTGRES_USER=admin",
    "POSTGRES_PASSWORD=supersecret",
    "POSTGRES_DB=portfoliodb"
  ]
  
  ports {
    internal = 5432
    external = 5432
  }
}