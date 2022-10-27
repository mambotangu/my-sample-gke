//NAT Related Variables

variable "enable_cloud_nat" {
    type = bool
    description = "Enable Cloud NAT for GKE Worker Nodes"
}

variable "nat_ip_allocate_option" {
    type = string
    description = "NAT IP Allocation Option"
}

variable "cloud_nat_address_count" {
    description = "The count of external ip address(es) to assign to the cloud-nat Object"
    type = number
}

variable "cloud_nat_tcp_transitory_idle_timeout_sec" {
  description = "Timeout in seconds for TCP transitory connections."
  type        = number
}

variable "cloud_nat_min_ports_per_vm" {
  description = "Minimum number of ports allocated to a VM from this NAT."
  type        = number
}

variable "cloud_nat_log_config_filter" {
  //default = null
}

variable "source_subnetwork_ip_ranges_to_nat" {
  description = "How NAT should be configured per subnetwork"
  type = string
}    

//Network Related Variables

variable "vpc_network_name" {
  type = string
  description = "Name of VPC Network for GKE Cluster"
}

variable "subnetwork_name" {
  type = string
  description = "Name of Subnet inside VPC Network for GKE Cluster"
}

variable "subnetwork_node_range" {
  type = string
  description = "Subnetwork for GKE Compute Nodes"
}

variable "subnetwork_pod_range" {
  type = string
  description = "Subnetwork for GKE Pods"
}

variable "subnetwork_pod_range_name" {
  type = string
  description = "Subnetwork for GKE Pods"
}

variable "subnetwork_service_range" {
  type = string
  description = "Subnetwork for GKE Services"
}

variable "subnetwork_service_range_name" {
  type = string
  description = "Subnetwork for GKE Services"
}

//Project Related Variables

variable "compute_region" {
    type = string
    description = "Region in which GKE Cluster to deploy"
}

variable "project_name" {
    type = string
    description = "Project in which GKE Cluster to deploy"
}

//GKE Cluster and NodePool related variables

variable "gke_cluster_name" {
  type = string
  description = "The Name of GKE Cluster"
}

variable "gke_num_nodes" {
  type = number
  description = "Number of Compute Nodes"
}

variable "enable_preemptible_machines" {
  type = bool
  description = "Enable or Disable Preemtible Machines"
}

variable "machine_type" {
  type = string
  description = "Machine type for GKE compute nodes"
}

variable "remove_default_node_pool" {
  type = bool
  description = "Flag to remove/keep default node pool"
}

variable "initial_node_count" {
  type = number
  description = "Initial Node Count in the Default node pool"
}

variable "enable_private_nodes" {
  type = bool
  description = "To Enable/Disable Private Nodes for GKE"
}

variable "enable_private_endpoint" {
  type = bool
  description = "To Enable/Disable Private endpoints"
}

variable "master_ipv4_cidr_block" {
  type = string
  description = "CIDR Block of GKE Master(s)"
}

variable "gke_node_pool_name" {
  type = string
  description = "GKE Node Pool Name"
}
 
