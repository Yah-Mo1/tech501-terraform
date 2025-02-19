
variable "address_space" {
  description = "The address space for the virtual network"
  default     = ["10.0.0.0/16"]

}

variable "vnet-name" {
  description = "The name of the vnet"
  default     = "tech501-yahya-2-subnet-vnet"

}