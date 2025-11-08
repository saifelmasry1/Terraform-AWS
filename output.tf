output "vpc_id" {
  value       = aws_vpc.terraform_electron_vpc.id
  description = "The ID of the terraform electron VPC"
  depends_on  = [aws_vpc.terraform_electron_vpc]
  sensitive   = false
}

output "public_subnet_id" {
  value       = aws_subnet.public_subnet.id
  description = "The ID of the public subnet"
  depends_on  = [aws_subnet.public_subnet]
  sensitive   = false
}
output "private_subnet_id" {
  value       = aws_subnet.private_subnet.id
  description = "The ID of the private subnet"
  depends_on  = [aws_subnet.private_subnet]
  sensitive   = false
}
output "internet_gateway_id" {
  value       = aws_internet_gateway.internet_gateway.id
  description = "The ID of the internet gateway"
  depends_on  = [aws_internet_gateway.internet_gateway]
  sensitive   = false
}
output "nat_gateway_id" {
  value       = aws_nat_gateway.NAT_Gateway.id
  description = "The ID of the NAT gateway"
  depends_on  = [aws_nat_gateway.NAT_Gateway]
  sensitive   = false
}
output "nat_gateway_ip" {
  value       = aws_eip.lb.public_ip
  description = "The public IP of the NAT gateway"
  depends_on  = [aws_eip.lb]
  sensitive   = false
}

output "terraform-electron-ec2_public_ip" {
  value       = aws_instance.terraform-electron-ec2.public_ip
  description = "The public IP address of the EC2 instance"
  depends_on  = [aws_instance.terraform-electron-ec2]
  sensitive   = false
}
output "terraform-electron-ec2_id" {
  value       = aws_instance.terraform-electron-ec2.id
  description = "The ID of the EC2 instance"
  depends_on  = [aws_instance.terraform-electron-ec2]
  sensitive   = false
}

output "security_group_id" {
  value       = aws_security_group.terraform-electron-security-group.id
  description = "The ID of the EC2 security group"
  depends_on  = [aws_security_group.terraform-electron-security-group]
  sensitive   = false
}

