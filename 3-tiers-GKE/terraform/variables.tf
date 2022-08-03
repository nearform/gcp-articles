variable "project_id" {
}

variable "app_name" {
  default = "app-3t-gke"
}

variable "region" {
  default = "us-central1"
}

variable "app_ip_range" {
  default = "10.1.0.0/16"
}

variable "app_machine_type" {
  default = "e2-small"
}

variable "app_disk_size_gb" {
  default = 10
}

variable "redis_memory_size_gb" {
  default = 1
}
