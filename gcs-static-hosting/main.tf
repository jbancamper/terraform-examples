provider "google" {
  project = "bancamp"
  region  = "us-east4"
  zone    = "us-east4-a"
  # version     = "3.3"
  credentials = file("../credentials/bancamp-55cdbfb56f80.json")
}

provider "google-beta" {
  project = "bancamp"
  region  = "us-east4"
  zone    = "us-east4-a"
  # version     = "3.3"
  credentials = file("../credentials/bancamp-55cdbfb56f80.json")
}

module "website_bucket" {
  source          = "./modules"
  application     = "test"
  site_name       = "test.bancamper.com"
  error_page_name = "index.html"
}
