terraform {
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
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "portfolio_web" {
  image = docker_image.nginx.image_id
  name  = "portfolio-server-lokal"
  restart = "always"
  ports {
    internal = 80
    external = 8080
  }
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