output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2_instance[*].id
}