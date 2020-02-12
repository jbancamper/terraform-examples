provider "google" {
  project     = "bancamp"
  region      = "us-east4"
  zone        = "us-east4-a"
  version     = "3.3"
  credentials = file("../credentials/bancamp-1a4dac6d6144.json")
}

module "cloud_run_service" {
  source      = "./modules"
  application = "portfolio"
}
