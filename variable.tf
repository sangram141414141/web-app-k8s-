variable "region" {
  description = "Azure region"
  default     = "East US"
}

variable "aks_cluster_name" {
  description = "AKS cluster name"
  default     = "web-app-cluster"
}

variable "node_type" {
  description = "VM size for worker nodes in AKS"
  default     = "Standard_DS2_v2"
}
