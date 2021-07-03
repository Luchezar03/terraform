variable "env_id" {
  description = "The ID of enviroment"
  type        = string
  default     = "pyshuk"
}

variable "location" {
  description = "The specific region in MS Azure"
  type        = string
  default     = "westus2" #West US
}

variable "vnet_cidr" {
  description = "The vnet CIDR"
  type        = string
  default     = "10.10.0.0/16"
}

variable "user_password" {
  default = "1234567qwe-"
}

variable "vms" {
  description = "The map of vms properties"
  type        = map(any)
  default = {
    vm1 = {
      size                 = "Standard_F2"
      caching              = "ReadWrite"
      storage_account_type = "Standard_LRS"
      publisher            = "MicrosoftWindowsServer"
      offer                = "WindowsServer"
      sku                  = "2016-Datacenter"
      version              = "latest"
      zone                 = "1"
    }
    vm2 = {
      size                 = "Standard_F2"
      caching              = "ReadWrite"
      storage_account_type = "Standard_LRS"
      publisher            = "MicrosoftWindowsServer"
      offer                = "WindowsServer"
      sku                  = "2016-Datacenter"
      version              = "latest"
      zone                 = "2"
    }
  }
}

variable "tags" {
  type = map(string)
  default = {
    "Owner"      = "yurapyshuk@gmail.com"
    "CostCenter" = "8904"
  }
}
