### LOCALS ###

locals {
  ingress_rules = [{
    name        = "https"
    port        = 443
    description = "Ingress rules for port 443"
    },
    {
      name        = "http"
      port        = 80
      description = "Ingress rules for port 80"
    },
    {
      name        = "ssh"
      port        = 22
      description = "Ingress rules for port 22"
  }]

}

### SECURITY GROUP ###

resource "aws_security_group" "security_group" {

  name        = "Custom_security_group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.nginx_vpc.id
  egress = [
    {
      description      = "Security group for outgoing traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  dynamic "ingress" {
    for_each = local.ingress_rules

    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = {
    Name = "AWS security group dynamic ingress block"
  }

}
