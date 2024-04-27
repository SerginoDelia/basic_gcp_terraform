# create network
resource "google_compute_network" "auto-vpc-tf" {
  name                    = "auto-vpc-tf"
  auto_create_subnetworks = true
}

# VPC Network
resource "google_compute_network" "custom-vpc-tf" {
  name                    = "custom-vpc-tf"
  auto_create_subnetworks = false
}

# subnet
resource "google_compute_subnetwork" "sub-useast" {
  name                     = "sub-useast"
  network                  = google_compute_network.custom-vpc-tf.id
  ip_cidr_range            = "10.177.0.0/24"
  region                   = "us-east1"
  private_ip_google_access = false
}

# Firewall rules
resource "google_compute_firewall" "allow-icmp" {
  name    = "allow-icmp"
  network = google_compute_network.custom-vpc-tf.id
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  source_ranges = ["0.0.0.0/0"]
  priority      = 1000
}

// display output
output "auto" {
  value = google_compute_network.auto-vpc-tf.id
}

output "custom" {
  value = google_compute_network.custom-vpc-tf.id
}
