## variables
variable "region" {
  type    = string
  default = "ap-northeast-3"

}

variable "instance_type" {
  type    = string
  default = "t2.micro"
  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("t2.micro", var.instance_type))
    error_message = "The instance_type value must be a valid."
  }
}

# variable "vpc_id" {
#   type = string
#   default = "vpc-0c3976bf5269cbc19"
# }

# variable "subnet_id" {
#   type = string
#   default = "subnet-05a487c60d5ad8fc1"
# }