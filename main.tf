# On IAM and Service account
# Add owner role
# add storage admin role


terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.25.0"
    }
  }
}

provider "google" {
  # Configuration options
  project     = "iamagwe"
  region      = "us-east1"
  zone        = "us-east1-b"
  credentials = "iamagwe-40a98105e9fd.json"
}

resource "google_storage_bucket" "bucket" {
  name          = "terraformorlizzo"
  location      = "US"
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "error.html"
  }

  uniform_bucket_level_access = false
}

// Setting the bucket ACL to public read
resource "google_storage_bucket_acl" "bucket_acl" {
  bucket         = google_storage_bucket.bucket.name
  predefined_acl = "publicRead"
}

// Uploading and setting public read access for HTML files
resource "google_storage_bucket_object" "upload_html" {
  for_each     = fileset("${path.module}/", "*.html")
  bucket       = google_storage_bucket.bucket.name
  name         = each.value
  source       = "${path.module}/${each.value}"
  content_type = "text/html"
}

// Public ACL for each HTML file
resource "google_storage_object_acl" "html_acl" {
  for_each       = google_storage_bucket_object.upload_html
  bucket         = google_storage_bucket_object.upload_html[each.key].bucket
  object         = google_storage_bucket_object.upload_html[each.key].name
  predefined_acl = "publicRead"
}

// Uploading and setting public read access for image files
resource "google_storage_bucket_object" "upload_images" {
  for_each     = fileset("${path.module}/", "*.jpg")
  bucket       = google_storage_bucket.bucket.name
  name         = each.value
  source       = "${path.module}/${each.value}"
  content_type = "image/jpeg"
}

// Public ACL for each image file
resource "google_storage_object_acl" "image_acl" {
  for_each       = google_storage_bucket_object.upload_images
  bucket         = google_storage_bucket_object.upload_images[each.key].bucket
  object         = google_storage_bucket_object.upload_images[each.key].name
  predefined_acl = "publicRead"
}

output "website_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.bucket.name}/index.html"
}

# Create an auto VPC with one subnet

resource "google_compute_network" "auto-vpc-tf" {
  name                    = "auto-vpc-tf"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "sub-useast" {
  name          = "sub-useast"
  network       = google_compute_network.auto-vpc-tf.id
  ip_cidr_range = "10.177.10.0/24"
  region        = "us-east1"
}


#resource "google_compute_network" "custom-vpc-tf" {
#name = "custom-vpc-tf"
#auto_create_subnetworks = false
#}

output "auto" {
  value = google_compute_network.auto-vpc-tf.id
}

#output "custom" {
#  value = google_compute_network.custom-vpc-tf.id
#}
