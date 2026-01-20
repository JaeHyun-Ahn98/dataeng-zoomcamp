variable "credentials" {
  description = "My Credentials"
  default     = "./keys/my-creds.json"
}

variable "project" {
  description = "Project"
  default     = "alpine-agent-484902-n5"
}

variable "region" {
  description = "Region"
  default     = "asia-northeast1"
}

variable "location" {
  description = "Project Location"
  default     = "asia-northeast1"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "demo_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default     = "alpine-agent-484902-n5-terra-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}