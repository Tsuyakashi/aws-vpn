variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-central-1"
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

variable "xray_port" {
  description = "Port for the VLESS+Reality inbound. 443 blends with normal HTTPS traffic and is recommended."
  type        = number
  default     = 443
}

variable "reality_dest" {
  description = "Domain to masquerade as for Reality (must serve TLS 1.3 + HTTP/2, no CDN in front of it, and its serverName must match). Check candidates with https://github.com/XTLS/Xray-core/discussions before changing."
  type        = string
  default     = "www.microsoft.com"
}

variable "client_name" {
  description = "Label embedded in the client link for identification."
  type        = string
  default     = "user-cfg"
}
