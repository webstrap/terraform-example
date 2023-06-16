output "wireguard_connection" {
  description = "Wireguard connection tuple"
  value = "${aws_eip.wireguard-bastion.public_ip}:${local.wireguard-server-port}"
}

output "wireguard_clients" {
  description = "Wireguard user map"
  value = local.wg_clients
}

output "service_deployments" {
  value = [
    for dep in module.service_deployments:
    dep
  ]

  sensitive = true
}
