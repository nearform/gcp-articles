variable "project_id" {
}

variable "app_name" {
  default = "app-3t-serverless"
}

variable "region" {
  default = "us-central1"
}

variable "regis_memory_size_gb" {
  default = 1
}

variable "app_ip_range" {
  default = "10.1.0.0/28"
}
