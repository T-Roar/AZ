variable "name" {
  type    = string
  default = "arg"
}

variable "location" {
  type    = string
  default = "East us"
}

variable "address" {
  type    = list(string)
  default = ["10.0.0.0/24"]
}

variable "network" {
  type    = string
  default = "tpvnet"
}

variable "storage_account_name" {
  type    = string
  default = "tpstorage123"
}

variable "storage_container_name" {
  type    = string
  default = "tom84"
}