variable "location" {
  type    = string
  default = "eastus"
}

variable "zones" {
  type    = list(string)
  default = []
}
variable "ssh-source-address" {
  type    = string
  default = "*"
}
variable "failover_location" {
  type    = string
  default = "eastus2"
}

variable "prefix" {
  type    = string
  default = "demo"
}

variable "private-cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "FrontEndAddress" {
    type = string
    default = "10.0.2.200"
  
}

variable "rdp-source-address" {
  type = string
  default = "*"
}

