### EC2 INSTANCE ###

resource "aws_instance" "ec2" {
  count                = length(aws_subnet.public_subnet.*.id)
  instance_type        = "t2.micro"
  ami                  = var.ami_id
  subnet_id            = element(aws_subnet.public_subnet.*.id, count.index)
  security_groups      = [aws_security_group.security_group.id, ]
  key_name             = "ssh_key_pair"
#   iam_instance_profile = data.aws_iam_role.iam_role.name

  tags = {
    "Name"        = "ec2-${count.index}"
    "Environment" = "Test"
    "CreatedBy"   = "Terraform"
  }
  timeouts {
    create = "10m"
  }
}

### Used as container for actions taken by provisioner ###
resource "null_resource" "nothingtoseehere" {
  count = length(aws_subnet.public_subnet.*.id)

  // Indicates where userdata.sh provisioning file is and destination or ec2 instances once live
  provisioner "file" {
    source      = "userdata.sh"
    destination = "/home/ec2-user/userdata.sh"
  }
  // Makes userdata.sh executable by converting to bash script    
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/userdata.sh",
      "sh /home/ec2-user/userdata.sh",
    ]
    on_failure = continue
  }

### Public SSH key ###
  key_name = aws_key_pair.keys.id

  connection {
    type        = "ssh"
    user        = "ec2-user"
    port        = "22"
    host        = element(aws_eip.elastic.*.public_ip, count.index)
    private_key = file("${var.PRIVATE_KEY_PATH}")
  }
}

### ELASTIC IPS ###

resource "aws_eip" "elastic" {
  count            = length(aws_instance.ec2.*.id)
  instance         = element(aws_instance.ec2.*.id, count.index)
  public_ipv4_pool = "amazon"
  vpc              = true

  tags = {
    "Name" = "eip-${count.index}"
  }
}

### ASSOCIATING EIP W/ EC2 INSTANCES

resource "aws_eip_association" "eip_association" {
  count         = length(aws_eip.elastic)
  instance_id   = element(aws_instance.ec2.*.id, count.index)
  allocation_id = element(aws_eip.elastic.*.id, count.index)
}