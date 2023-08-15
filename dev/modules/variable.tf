variable "subnets_count" {
  type    = list(string)
  default = ["subnet1", "subnet2"]
}


variable "availability_zone" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "instance_ami" {
  type    = string
  default = "ami-053b0d53c279acc90"
}

variable "instance_size" {
  type    = string
  default = "t2.micro"
}

