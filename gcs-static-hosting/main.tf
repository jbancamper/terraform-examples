provider "google" {
  project     = "bancamp"
  region      = "us-east4"
  zone        = "us-east4-a"
  version     = "3.3"
  credentials = file("../credentials/bancamp-81d09ecff6b7.json")
}

module "website_bucket" {
  source          = "./modules"
  site_name       = "health-app.bancamper.com"
  error_page_name = "index.html"
  log_prefix      = "health-app"
}
