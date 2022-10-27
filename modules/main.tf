locals {
  ## the following locals modify resource creation behavior depending on var.nat_ip_allocate_option
  enable_cloud_nat        = var.enable_cloud_nat == true ? 1 : 0
  cloud_nat_address_count = var.nat_ip_allocate_option != "AUTO_ONLY" ? var.cloud_nat_address_count * local.enable_cloud_nat : 0
  nat_ips                 = var.nat_ip_allocate_option != "AUTO_ONLY" ? google_compute_address.ip_address.*.self_link : null
}

//Create GKE VPC 

resource "google_compute_network" "network" {
  name                    = var.vpc_network_name
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
  project = var.project_name
}

//Create Subnets for GKE VPC

resource "google_compute_subnetwork" "subnetwork" {
  name                     = var.subnetwork_name
  project                  = var.project_name
  ip_cidr_range            = var.subnetwork_node_range
  network                  = google_compute_network.network.self_link
  region                   = var.compute_region
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = var.subnetwork_pod_range_name
    ip_cidr_range = var.subnetwork_pod_range
  }

  secondary_ip_range {
    range_name    = var.subnetwork_service_range_name
    ip_cidr_range = var.subnetwork_service_range
  }
}

//Create Cloud Router for NAT Purposes

resource "google_compute_router" "router" {
  count   = local.enable_cloud_nat
  project = var.project_name
  name    = var.vpc_network_name
  network = google_compute_network.network.self_link
  region  = var.compute_region
}

//Create Google Compute address for NAT Purposes in case NAT_IP_Allocation is not set to AUTO_ONLY

resource "google_compute_address" "ip_address" {
  project = var.project_name
  count  = local.cloud_nat_address_count
  name   = "nat-external-address-${count.index}"
  region = var.compute_region
}

//Create NAT Router 

resource "google_compute_router_nat" "nat_router" {
  count                              = local.enable_cloud_nat
  name                               = var.vpc_network_name
  router                             = google_compute_router.router.0.name
  region                             = var.compute_region
  project                            = var.project_name
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  nat_ips                            = local.nat_ips
  min_ports_per_vm                   = var.cloud_nat_min_ports_per_vm
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat
  tcp_transitory_idle_timeout_sec    = var.cloud_nat_tcp_transitory_idle_timeout_sec

  log_config {
    enable = var.cloud_nat_log_config_filter == null ? false : true
    filter = var.cloud_nat_log_config_filter == null ? "ALL" : var.cloud_nat_log_config_filter
  }
}

//Create the GKE Cluster

resource "google_container_cluster" "primary" {
  name     = var.gke_cluster_name
  project  = var.project_name
  location = var.compute_region
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = var.remove_default_node_pool
  initial_node_count       = var.initial_node_count
  network = resource.google_compute_network.network.name
  subnetwork = resource.google_compute_subnetwork.subnetwork.name
  ip_allocation_policy {
    cluster_secondary_range_name = resource.google_compute_subnetwork.subnetwork.secondary_ip_range[0].range_name 
    services_secondary_range_name = resource.google_compute_subnetwork.subnetwork.secondary_ip_range[1].range_name
  }
  private_cluster_config {
      enable_private_nodes = var.enable_private_nodes
      enable_private_endpoint = var.enable_private_endpoint
      master_ipv4_cidr_block = var.master_ipv4_cidr_block
  }
}

//Create the GKE Node Pool

resource "google_container_node_pool" "node_pool" {
  name     = var.gke_node_pool_name
  location = var.compute_region
  project = var.project_name
  cluster = google_container_cluster.primary.name
  node_count = var.gke_num_nodes
  node_config {
    preemptible = var.enable_preemptible_machines
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
