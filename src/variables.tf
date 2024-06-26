variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "Web Server"
}


# for use Terraform Cloud env var
variable "INSTANCE_NAME" {
  type = string
  default = ""
}
variable "INSTANCE_TYPE" {
  type = string
  default = ""
}
variable "INSTANCE_AMI" {
  type = string
  default = ""
}