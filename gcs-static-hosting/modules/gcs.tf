variable "site_name" {}

variable "bucket_location" {
  default = "US"
}

variable "bucket_storage_class" {
  default = "STANDARD"
}

variable "index_page_name" {
  default = "index.html"
}

variable "error_page_name" {
  default = "error.html"
}

variable "origins" {
  default = ["*"]
}

variable "access_control_max_age" {
  default = "0"
}

variable "access_control_group" {
  default = "allUsers"
}

variable "access_control_group_role" {
  default = "READER"
}

resource "google_storage_bucket" "website_storage_bucket" {
  name          = "test-bucket-bancamper"
  location      = var.bucket_location
  storage_class = var.bucket_storage_class

  website {
    main_page_suffix = var.index_page_name
    not_found_page   = var.error_page_name
  }

  cors {
    origin          = var.origins
    method          = ["GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD"]
    max_age_seconds = var.access_control_max_age
  }

}

resource "google_storage_bucket_access_control" "public_rule" {
  bucket = google_storage_bucket.website_storage_bucket.name
  role   = var.access_control_group_role
  entity = var.access_control_group
}

resource "google_storage_default_object_access_control" "object_public_rule" {
  bucket = google_storage_bucket.website_storage_bucket.name
  role   = var.access_control_group_role
  entity = var.access_control_group
}
