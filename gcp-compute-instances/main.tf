provider "google" {
  project = "cluster-building"
  region = "us-east4"
  zone = "us-east4-a"
  version = "3.3"
  credentials = file("../credentials/cluster-building-1d1143207652.json")
}

module "kubernetes_master" {
  source = "./modules"
  project_name = "cluster-building"
  instance_name = "kubernetes-master" 
}