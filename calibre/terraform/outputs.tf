output "domain" {
  value = var.domain_name
}

output "ec2_public_ip" {
  value = aws_eip.ec2_eip.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.ec2.id
}

output "s3_library_bucket" {
  value = aws_s3_bucket.library.bucket
}

output "iam_mac_access_key_id" {
  value = aws_iam_access_key.mac_keys.id
  sensitive = false
}

output "iam_mac_secret_access_key" {
  value     = aws_iam_access_key.mac_keys.secret
  sensitive = true
}