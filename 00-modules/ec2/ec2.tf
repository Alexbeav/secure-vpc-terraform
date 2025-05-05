resource "aws_instance" "public" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.bastion_subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.bastion_sg_id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    sed -i 's/^#\\?AllowAgentForwarding.*/AllowAgentForwarding yes/' /etc/ssh/sshd_config
    systemctl restart sshd
    echo "Agent forwarding enabled" >> /var/log/user-data.log 2>&1
  EOF

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = merge(var.tags, {
    Name = "bastion-instance"
  })

  root_block_device {
    encrypted = true
  }
}


resource "aws_instance" "private" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.private_sg_id]
  associate_public_ip_address = false

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }


  tags = merge(var.tags, {
    Name = "private-instance"
  })

  root_block_device {
    encrypted = true
  }
}
