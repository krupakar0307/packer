## variables
variable "region" {
  type    = string
  default = "us-east-1"

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

