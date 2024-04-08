data "azurerm_dns_zone" "cloudaccelerator" {
  name = "cloudaccelerator.dev"
}

data "azurerm_resource_group" "website" {
  name = "website"
}

resource "azurerm_static_web_app" "website" {
  name                = "website"
  resource_group_name = data.azurerm_resource_group.website.name
  location            = data.azurerm_resource_group.website.location

  sku_tier = "Free"
  sku_size = "Free"

  preview_environments_enabled = false

  tags = {
    repo = var.repo
  }
}

resource "azurerm_static_web_app_custom_domain" "website" {
  static_web_app_id = azurerm_static_web_app.website.id
  domain_name       = data.azurerm_dns_zone.cloudaccelerator.name
  validation_type   = "dns-txt-token"
}

resource "azurerm_static_web_app_custom_domain" "website_www" {
  static_web_app_id = azurerm_static_web_app.website.id
  domain_name       = trimsuffix(azurerm_dns_cname_record.website.fqdn, ".")
  validation_type   = "cname-delegation"
}

resource "azurerm_dns_txt_record" "website_validation" {
  zone_name           = data.azurerm_dns_zone.cloudaccelerator.name
  resource_group_name = data.azurerm_dns_zone.cloudaccelerator.resource_group_name

  name = "_dnsauth"
  ttl  = 3600

  record {
    value = length(local.dns_validation_token) > 0 ? local.dns_validation_token : "placeholder"
  }

  lifecycle {
    ignore_changes = [record]
  }
}

resource "azurerm_dns_a_record" "website" {
  zone_name           = data.azurerm_dns_zone.cloudaccelerator.name
  resource_group_name = data.azurerm_dns_zone.cloudaccelerator.resource_group_name

  name = "@"
  ttl  = 3600

  target_resource_id = azurerm_static_web_app.website.id
}

resource "azurerm_dns_cname_record" "website" {
  zone_name           = data.azurerm_dns_zone.cloudaccelerator.name
  resource_group_name = data.azurerm_dns_zone.cloudaccelerator.resource_group_name

  name = "www"
  ttl  = 3600

  record = azurerm_static_web_app.website.default_host_name
}

locals {
  dns_validation_token = azurerm_static_web_app_custom_domain.website.validation_token
}
