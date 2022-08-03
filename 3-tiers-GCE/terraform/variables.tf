variable "project_id" {
}

variable "app_name" {
  default = "app-3t-gce"
}

variable "region" {
  default = "us-central1"
}

variable "app_ip_range" {
  default = "10.1.0.0/16"
}

variable "image_family" {
  default = "debian-10"
}

variable "image_project" {
  default = "debian-cloud"
}

variable "app_machine_type" {
  default = "e2-small"
}

variable "redis_memory_size_gb" {
  default = 1
}