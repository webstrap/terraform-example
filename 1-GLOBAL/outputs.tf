output "root_zone_id" {
  value = aws_route53_zone.primary.id
}

output "instance_profile_role_name" {
  value = aws_iam_instance_profile.instance_role.name
}

output "instance_profile_role_arn" {
  value = aws_iam_instance_profile.instance_role.arn
}

output "instance_role" {
  value = aws_iam_role.instance_role.arn
}

output "route53_zone_cert_arn" {
  value = aws_acm_certificate.default.arn
}

output "ue1_route53_zone_cert_arn" {
  value = aws_acm_certificate.ue1[0].arn
}

output "developer_access" {
  value = [
    for dev, val in aws_iam_user_login_profile.users_login_profile["developers"]:
    { name = dev, enc_pwd = val.encrypted_password }
  ]
}

output "admin_access" {
  value = [
    for dev, val in aws_iam_user_login_profile.users_login_profile["admins"]:
    { name = dev, enc_pwd = val.encrypted_password }
  ]
}
