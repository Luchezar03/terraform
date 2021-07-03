provider "azurerm" {
  subscription_id = "2460f6b9-6b8a-4580-9044-7279e6d71e2d"
  tenant_id       = "33715ef8-aa8a-43d6-83bb-34f7e9d223f6"

  features {}
}

terraform {
  required_version = ">= 0.14.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.65.0"
    }
  }
}
