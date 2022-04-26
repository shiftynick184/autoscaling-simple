output "private_ip" {
  value = zipmap(aws_instance.ec2.*.tags.Name, aws_instance.ec2.*.private_ip)
}

output "public_ip" {
  value = zipmap(aws_instance.ec2.*.tags.Name, aws_eip.elastic.*.public_ip)
}

output "public_dns" {
  value = zipmap(aws_instance.ec2.*.tags.Name, aws_eip.elastic.*.public_dns)
}

output "private_dns" {
  value = zipmap(aws_instance.ec2.*.tags.Name, aws_instance.ec2.*.private_dns)
}

output "alb_id" {
  value = aws_lb.app_load_balancer.dns_name
}