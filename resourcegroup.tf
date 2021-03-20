resource "azurerm_resource_group" "lab" {
  name     = "rg-projeto-cloud-eastus"
  location = var.location
}