# Packer

[Packer](https://developer.hashicorp.com/packer/docs) is an open source tool for creating customized AMIs of different environments. It is a lightweight and runs on every operating system.

A machine image is a single static unit that contains a pre-configured operating system and installs required software on it, which is used to quickly create new running machines., Once AMI is created with all required packages, then it is easy to spin up an instance with this pre-baked AMIs.

#### Packer does not replace configuration management like Chef or Puppet. In fact, when building images, Packer is able to use tools like Chef or Puppet to install software onto the image.


## Why Packer?
Packer is the tool where to automate for creating pre-baked or customized AMI's.
### Advantages:
- #### Super fast infrastructure deployment : 
  Packer facilitates rapid infrastructure deployment, allowing for the launch of fully provisioned and configured.
- #### Multi-Provider Portability: 
  Packer creates identical images for various platforms with ensuring seamless portability across different environments (production, staging, development).
- #### Improved Stability: 
  By installing and configuring all software during image creation, Packer catches bugs early in the process, enhancing overall system stability.
- #### Ease of Use: 
  Packer simplifies the utilization of these benefits, making it a user-friendly tool for streamlined infrastructure management and deployment.
- #### Greater Testability:
  Built machine images can be swiftly launched and smoke tested, providing quick verification of proper functionality, instilling confidence in the reliability of subsequent machine instances.

### How to write Packer Template:
Packer template  is a configuration file (.pkr.hcl extension) where we write our required packages and configurations on AMI's OS.

This template consists of blocks:

Builders, source, Provisioners, Post-processors(Optional)

Builders: Builders create customized AMIs. Packer also has some builders that perform helper tasks, like running provisioners.

Source: Source is the base OS AMI configurations such type of instance, vloumes to be attach, ami_id, OS type etc.

Provisioners:
Provisioners use built-in and third-party software to install and configure the machine image after booting. Provisioners prepare the system

Data sources: Data sources allow data to be fetched or computed for use elsewhere in locals and sources configuration. Use of data sources allows a Builder to make use of information defined outside of Packer.

### Write a Packer template for Jenkins Install on Ubuntu AMI.
The above files consists of packer template consisting of pre-backed Jenkins AMI.
It consists of data source block to fetch an OS ami_id with filtered information:
```sh
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
```
The above block will get AMI_ID.

#### Source Configuration:
Source configuration is used to provide additional configuration for the AMI, so that durining launcing instance with AMI, there is no additonal congfigurations to be done such attach require volume capacity etc.
```sh
source "amazon-ebs" "jenkins-ami" {
  ami_name                                  = "jenkins_{{timestamp}}"
  instance_type                             = var.instance_type
  region                                    = var.region
  source_ami                                = local.source_ami_id
  ssh_username                              = "ubuntu"
  temporary_security_group_source_public_ip = true

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    delete_on_termination = true
    encrypted             = true
    volume_size           = 40
    volume_type           = "gp2"
  }
}
```
In Above `source_ami` i populated value from the data sourced block information. i retrieved ami_id with data source and used here instead of manually search source ami_id and assigning here.

Finally Builders block, will take the above source_ami OS and installs required packages which is mentioned in Provisioners block

```sh
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
```


Once template configruations are ready, (you may put all blocks in single file called packaer.pkr.hcl or you can split them accoriding blocks, it's on your convinient).

You can you variables to pass dynamically during runtime with commands, for eg: region, vpc_id, instance_type etc.
#### Variables:
In variable we can also use conditions for inputs, for eg: for dev environments you might want to use specific instance_type family, then put a condition in variables block. if your input not met with an conditions it pops an error.

eg:
```sh
variable "instance_type" {
  type    = string
  default = "t2.micro"
  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("t2.micro", var.instance_type))
    error_message = "The instance_type value must be a valid."
  }
}
```

#### Commands:
Commands to run packer validate and build.

- `packer validate .` (dot, where your files a placed). - This will validate your packer configuration.
- `packer build .` - This will builds your AMIs
- `packer build -var .` - This will pass run time vairables to your packer configuration
- 
For More CLI Commands and flags, Refer: https://developer.hashicorp.com/packer/docs/commands/build

=================================================================================

## How to use above packer configuration for Jenkins AMI
- Install packer in your machine based on OS type : [Install](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli#installing-packer)

- Clone the above code and place your inputs in variable file, uncomment `vpc_id` and `subnet_id` if you wanna build ami in non-default vpc.
- Then APply `packer validate .` to validate configuration and build AMI using `packer build .` That's all it will create an AMI in couple of minutes.

---