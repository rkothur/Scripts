module "ec-create" {
  source                      = "gitlab.spectrumflow.net/charter/aws-ec2/aws"
  version                     = "0.0.0-feature.4ee39bcc"
  ami_id                      = var.ami_id
  ec2_name                    = var.ec2_name
  subnet_id                   = var.subnet_id
  instance_type               = var.instance_type
  iam_instance_profile        = var.iam_instance_profile
  vpc_security_group_ids      = var.security_group_ids

  tags = var.tags
}
