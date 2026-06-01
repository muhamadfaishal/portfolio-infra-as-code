# 🚀 Enterprise GitOps & Infrastructure as Code (IaC) Portfolio

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/ansible-%231A1918.svg?style=for-the-badge&logo=ansible&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=Prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/grafana-%23F46800.svg?style=for-the-badge&logo=grafana&logoColor=white)

## 📌 Overview
Proyek ini adalah simulasi lingkungan kerja *DevOps* tingkat produksi yang dibangun dari nol. Repositori ini mendemonstrasikan implementasi praktik **GitOps** penuh, di mana pembaruan infrastruktur, manajemen konfigurasi, dan pemantauan sistem diotomatisasi sepenuhnya melalui CI/CD *pipeline*.

## 🏗️ Architecture Flow
Sistem ini menggunakan arsitektur modern berbasis *container* dengan alur kerja sebagai berikut:
1. **Source of Truth:** Pengembang melakukan *push* kode (web HTML) atau deklarasi infrastruktur ke repositori GitHub (`main` branch).
2. **CI/CD Pipeline:** GitHub Actions mendeteksi perubahan dan memicu *Self-Hosted Runner*.
3. **Infrastructure Provisioning:** Terraform dieksekusi secara otomatis untuk membangun atau memperbarui *container* Docker (Nginx web server & Monitoring Stack).
4. **Configuration Management:** Ansible mengambil alih untuk mengonfigurasi *server* Nginx dan menyuntikkan *file* web portofolio terbaru tanpa *downtime*.
5. **Observability Stack:** cAdvisor mengumpulkan metrik dari mesin Docker, Prometheus menarik (*scrape*) data tersebut, dan Grafana menyajikannya dalam visualisasi *real-time*.

## 🛠️ Technology Stack
* **Infrastructure Provisioning:** Terraform
* **Configuration Management:** Ansible
* **CI/CD Automation:** GitHub Actions (Self-Hosted Runner)
* **Containerization:** Docker
* **Web Server:** Nginx
* **Monitoring & Observability:** cAdvisor, Prometheus, Grafana

## 🚀 Fitur Utama
* **Zero-Touch Deployment:** Perubahan teks sekecil apa pun pada kode web akan langsung ter-*deploy* ke dalam *container* tanpa perlu eksekusi manual (GitOps).
* **Infrastructure as Code (IaC):** Seluruh *server* dan agen pemantauan dideklarasikan secara deterministik melalui berkas `main.tf`.
* **Real-time Observability:** Metrik CPU, Memory, dan Network *traffic* dilacak menggunakan kombinasi Prometheus dan Grafana.

## 📝 Technical Notes & Findings (WSL2 Architecture)
> **Known Limitation:** Proyek ini dikembangkan di lingkungan lokal menggunakan Windows Subsystem for Linux (WSL2). Karena arsitektur WSL2 menyembunyikan metrik *container* di dalam isolasi *Virtual Hard Disk* (`docker-desktop-data`), cAdvisor memerlukan injeksi `privileged = true` pada Terraform untuk membaca data memori dan CPU secara akurat. Kode IaC di repositori ini sudah 100% *production-ready* untuk dieksekusi di *Native Linux Cloud Server* (AWS/GCP/DO) tanpa memerlukan modifikasi tambahan.

## ⚙️ How to Run Locally
Jika ingin menjalankan infrastruktur ini di mesin lokal:
1. Pastikan Docker Daemon berjalan.
2. Lakukan inisiasi dan *apply* infrastruktur:
   ```bash
   cd infra
   terraform init
   terraform apply -auto-approve```
3. Konfigurasi web server menggunakan Ansible:
    ```bash
    ansible-playbook -i inventory.ini playbook.yml```
4. Akses sistem melalui browser:
    - **Web App:** http://localhost:8080
    - **Grafana Dashboard:** http://localhost:3000
