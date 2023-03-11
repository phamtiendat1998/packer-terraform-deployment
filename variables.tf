variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "commonTagName" {
  description = "The Azure Tag in which all resources in this example should be created."
}

variable "virtualMachineCount" {
  description = "The number of virtual machines will be deploy."
}