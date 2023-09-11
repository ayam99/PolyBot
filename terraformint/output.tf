output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "az" {
  description = "az's in us-east-1"
  value       = data.aws_availability_zones.available_azs
}
