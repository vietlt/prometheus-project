variable "aws_region" {
  type = string
  default = "ap-southeast-1"
}

variable "availability_zone" {
  type    = list(any)
  default = ["ap-southeast-1a", "ap-southeast-1b"]
}
 
variable "public_cird" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "cidr_route" {
  type    = string
  default = "0.0.0.0/0"
}
