output "acr_login_server" {
  value = module.aks.acr_login_server
  sensitive = true
}

output "acr_name" {
  value = module.aks.acr_name
  sensitive = true
}
