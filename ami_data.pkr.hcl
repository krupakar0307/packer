
// data block to retrive ami id from specific region

data "amazon-ami" "jenkins-ami" {
  filters = {
    virtualization-type = "hvm"
    name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
  }
  owners      = ["amazon"]
  most_recent = true
  region      = var.region
}