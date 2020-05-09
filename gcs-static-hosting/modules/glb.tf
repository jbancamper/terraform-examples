variable "application" {}

variable "load_balancer_scope" {
  description = "INTERNAL or EXTERNAL"
  default     = "EXTERNAL"
}

variable "ip_version" {
  default = "IPV4"
}

variable "ip_protocol" {
  default = "TCP"
}

variable "ssl_profile" {
  default = "MODERN"
}

variable "tls_version" {
  default = "TLS_1_2"
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "${var.application}-https-listener"
  target                = google_compute_target_https_proxy.gcs_https_proxy.self_link
  load_balancing_scheme = var.load_balancer_scope
  port_range            = "443"
  ip_version            = var.ip_version
  ip_protocol           = var.ip_protocol
}

resource "google_compute_target_https_proxy" "gcs_https_proxy" {
  name             = "${var.application}-https-proxy"
  url_map          = google_compute_url_map.lb_to_gcs.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.lb_ssl_cert.self_link]
  ssl_policy       = google_compute_ssl_policy.lb_ssl_policy.self_link
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${var.application}-http-listener"
  target                = google_compute_target_http_proxy.gcs_http_proxy.self_link
  load_balancing_scheme = var.load_balancer_scope
  port_range            = "80"
  ip_version            = var.ip_version
  ip_protocol           = var.ip_protocol
}

resource "google_compute_target_http_proxy" "gcs_http_proxy" {
  name    = "${var.application}-http-proxy"
  url_map = google_compute_url_map.lb_http_redirect.self_link
}

resource "google_compute_url_map" "lb_http_redirect" {
  name = "${var.application}-redirect"
  default_url_redirect {
    host_redirect          = var.site_name
    https_redirect         = true
    redirect_response_code = "FOUND"
    strip_query            = false
  }
}

resource "google_compute_url_map" "lb_to_gcs" {
  name            = "${var.application}-lb"
  default_service = google_compute_backend_bucket.gcs_service.self_link

  header_action {
    response_headers_to_add {
      header_name  = "Content-Security-Policy"
      header_value = "default-src"
      replace      = true
    }

  }

  host_rule {
    hosts        = [var.site_name]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_bucket.gcs_service.self_link

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_bucket.gcs_service.self_link
    }
  }

  test {
    service = google_compute_backend_bucket.gcs_service.self_link
    host    = var.site_name
    path    = "/${var.index_page_name}"
  }
}

resource "google_compute_backend_bucket" "gcs_service" {
  name        = "${var.application}-backend-bucket"
  bucket_name = google_storage_bucket.website_storage_bucket.name
  enable_cdn  = true

  cdn_policy {
    signed_url_cache_max_age_sec = "3600"
  }
}

resource "google_compute_managed_ssl_certificate" "lb_ssl_cert" {
  provider = google-beta
  name     = "${var.application}-certificate"

  managed {
    domains = [var.site_name]
  }
}

resource "google_compute_ssl_policy" "lb_ssl_policy" {
  name            = "${var.application}-tls-ssl-policy"
  profile         = var.ssl_profile
  min_tls_version = var.tls_version
}
