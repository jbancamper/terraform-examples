variable "application" {}

variable "project" {
  default = "bancamp"
}

variable "region" {
  default = "us-east4"
}

variable "container_port" {
  default = "8080"
}

variable "environment" {
  default = "dev"
}

data "google_iam_policy" "public_access_policy" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_service" "cloud_run_service" {
  name     = "${var.application}-service"
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.cloud_run_svc_acct.email
      containers {
        image = "gcr.io/${var.project}/${var.application}"

        # env {
        #   name  = "SPRING_PROFILES_ACTIVE"
        #   value = var.environment
        # }

        # resources {
        #   limits = {
        #     cpu    = "2048m"
        #     memory = "2048Mi"
        #   }

        #   requests = {
        #     cpu    = "1024m"
        #     memory = "1024m"
        #   }
        # }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_policy" "public_access" {
  location    = google_cloud_run_service.cloud_run_service.location
  project     = google_cloud_run_service.cloud_run_service.project
  service     = google_cloud_run_service.cloud_run_service.name
  policy_data = data.google_iam_policy.public_access_policy.policy_data
}

resource "google_cloud_run_service_iam_policy" "admin_access" {
  location    = google_cloud_run_service.cloud_run_service.location
  project     = google_cloud_run_service.cloud_run_service.project
  service     = google_cloud_run_service.cloud_run_service.name
  policy_data = data.google_iam_policy.cloud_run_admin.policy_data
}

output "cloud_run_url" {
  value = "${google_cloud_run_service.cloud_run_service.status[0].url}"
}
