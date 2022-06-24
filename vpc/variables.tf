#En este archivo, definiremos todas las variables que necesita Terraform

#IP pública
variable "my-public-ip" {
  type    = string
  #default = "92.190.147.54/32" (está definido en terraform.tfvars)
}

#AWS Region
variable "aws-region" {
  type = string
  description = "Región de AWS"
}


#Public Subnet
variable "public-ip-for-ec2" {
  type = bool
  description = "Define si le otorgamos una IP pública a instancia EC2"
}


#Public Subnet name 
variable "public-subnet-name" {
  type = string
}


#Private Subnet name 
variable "private-subnet-name" {
  type = string
}
