## Packer Plugin for aws
packer {
  required_plugins {
    amazon = {
      version = " >= 1.2.9"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


// in a local
locals {
  source_ami_id   = data.amazon-ami.jenkins-ami.id
  source_ami_name = data.amazon-ami.jenkins-ami.name
}

## source block for reuseable builder configuration
source "amazon-ebs" "jenkins-ami" {
  ami_name                                  = "jenkins_{{timestamp}}"
  instance_type                             = var.instance_type
  region                                    = var.region
  source_ami                                = local.source_ami_id
  ssh_username                              = "ubuntu"
  temporary_security_group_source_public_ip = true
  # vpc_id = var.vpc_id
  # subnet_id = var.subnet_id
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    delete_on_termination = true
    encrypted             = true
    volume_size           = 40
    volume_type           = "gp2"
  }
}
## Builder block to build an ami on above base ami with below provisioned packages.
build {
  sources = ["source.amazon-ebs.jenkins-ami"]
  provisioner "file" {
    source      = "scripts/jenkins_install.sh"
    destination = "/tmp/jenkins_install.sh"
  }
  provisioner "shell" {
    inline = [
      "cd /tmp && chmod +x /tmp/jenkins_install.sh",
      "sh jenkins_install.sh && rm jenkins_install.sh"
    ]
  }
}

