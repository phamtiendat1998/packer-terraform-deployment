variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "udacity"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "East US"
}

variable "commonTagName" {
  description = "The Azure Tag in which all resources in this example should be created."
  default = "Udacity Course 1"
}

variable "virtualMachineCount" {
  description = "The number of virtual machines will be deployed."
  default = 2

  validation {
    condition     = var.virtualMachineCount > 1 && var.virtualMachineCount < 6
    error_message = "The virtualMachineCount value for the count parameter should be at least 2, and for cost reasons, no more than 5."
  }
}