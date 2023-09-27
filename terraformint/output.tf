output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "az" {
  description = "az's in us-east-1"
  value       = data.aws_availability_zones.available_azs
}

output "vpc_public_subnets" {
  description = "IDs of the VPC's public subnets"
  value       = module.app_vpc.public_subnets
}

output "vpc_private_subnets" {
  description = "IDs of the VPC's public subnets"
  value       = module.app_vpc.private_subnets
}

output "vpc_id" {
  value = module.app_vpc.vpc_id
}
