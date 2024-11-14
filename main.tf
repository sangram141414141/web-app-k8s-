provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.aks_cluster_name}"
  location = var.region
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.aks_cluster_name}"
  location            = var.region
  address_space       = ["10.0.0.0/16"]
}

# Subnets for AKS Cluster
resource "azurerm_subnet" "subnet" {
  count              = 2
  name               = "subnet-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes    = [cidrsubnet(azurerm_virtual_network.vnet.address_space[0], 8, count.index)]
}

# Managed Identity for AKS Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = var.node_type
    vnet_subnet_id = azurerm_subnet.subnet[0].id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }

  depends_on = [
    azurerm_subnet.subnet
  ]
}

# Output AKS Cluster API Server URL
output "aks_cluster_endpoint" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config[0].host
}

