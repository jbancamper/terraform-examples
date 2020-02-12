data "google_iam_policy" "cloud_run_admin" {

  # Create, update, and delete Cloud Run config, revisions, logging, routes, and policy
  binding {
    role    = "roles/run.admin"
    members = ["serviceAccount:${google_service_account.cloud_run_svc_acct.email}"]
  }

  # Assume Cloud Run Service Agent Account
  binding {
    role    = "roles/iam.securityAdmin"
    members = ["serviceAccount:${google_service_account.cloud_run_svc_acct.email}"]
  }
}

resource "google_service_account" "cloud_run_svc_acct" {
  account_id  = "${var.application}-sa"
  description = "Service Account to run ${var.application}-service in Cloud Run"
}

# resource "google_service_account_iam_policy" "cloud_run_policy" {
#   service_account_id = google_service_account.cloud_run_svc_acct.name
#   policy_data        = data.google_iam_policy.cloud_run_admin.policy_data
# }
