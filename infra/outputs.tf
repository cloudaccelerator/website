output "app_id" {
  value = azurerm_static_web_app.website.id
}

output "fqdn" {
  value = trimsuffix(azurerm_dns_a_record.website.fqdn, ".")
}
