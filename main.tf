terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = var.region_name
}

data "aws_ami" "couchbase_ami" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name = "name"

    values = [
      "CentOS Linux 7 x86_64 HVM EBS *",
    ]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "random_id" "labid" {
  byte_length = 4
}

resource "aws_instance" "docker_node" {
  ami                    = data.aws_ami.couchbase_ami.id
  instance_type          = var.instance_type
  key_name               = var.ssh_key
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.subnet_id

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    iops        = var.root_volume_iops
  }

  tags = {
    Name = "docker-${random_id.labid.hex}"
    Role = "docker"
    LabName = "lab-${random_id.labid.hex}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/callhostprep.sh"
    destination = "/home/${var.ssh_user}/callhostprep.sh"
    connection {
      host        = self.private_ip
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.ssh_user}/callhostprep.sh",
      "/home/${var.ssh_user}/callhostprep.sh -t basic -h docker-${random_id.labid.hex}",
    ]
    connection {
      host        = self.private_ip
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
    }
  }
}
