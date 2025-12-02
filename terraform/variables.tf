variable "region" {
    description = "region"
    type = string
    default = "eu-central-1"
}

variable "instance_name" {
    description = "Value of the EC2 instance's Name tag."
    type        = string
    default     = "vpn-instance"
}

variable "instance_type" {
    description = "The EC2 instance's type."
    type        = string
    default     = "t2.micro"
}
variable "ami" {
    description = "Ubuntu 24.04 ami"
    type = string
    default = "ami-004e960cde33f9146"
}