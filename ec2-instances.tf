### EC2 INSTANCE WITH UBUNTU OS###

resource "aws_instance" "ec2" {
  count           = length(aws_subnet.public_subnet.*.id)
  instance_type   = "t2.micro"
  ami             = var.ami_id
  subnet_id       = element(aws_subnet.public_subnet.*.id, count.index)
  security_groups = [aws_security_group.security_group.id, ]
  key_name        = "test_key"
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

  // Indicates where user-data.sh provisioning file is and destination on ec2 instances once live
  provisioner "file" {
    source      = "user-data.sh"
    destination = "/home/ubuntu/user-data.sh" /// "/home/ubuntu/user-data.sh"
  }
  // Makes userdata.sh executable by converting to bash script    
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/user-data.sh",  ////home/ubuntu/user-data.sh"
      "sudo  /home/ubuntu/user-data.sh",    ////home/ubuntu/user-data.sh"
    ]
    # on_failure = continue
  }


  connection {
    type        = "ssh"
    agent       = "false"
    user        = "ubuntu"
    port        = "22"
    timeout     = "30s"
    host        = element(aws_eip.elastic.*.public_ip, count.index)
    private_key = file("${var.PRIVATE_KEY_PATH}")
  }
}

# ### Public SSH key ###
#   key_name = aws_key_pair.keys.id

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