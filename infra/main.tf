data "azurerm_dns_zone" "cloudaccelerator" {
  name = "cloudaccelerator.dev"
}

resource "azurerm_resource_group" "website" {
  name     = "website"
  location = "West Europe"
}

resource "azurerm_static_web_app" "website" {
  name                = "website"
  resource_group_name = azurerm_resource_group.website.name
  location            = azurerm_resource_group.website.location

  sku_tier = "Free"
  sku_size = "Free"

  preview_environments_enabled = false
}

resource "azurerm_static_web_app_custom_domain" "website" {
  static_web_app_id = azurerm_static_web_app.website.id
  domain_name       = "cloudaccelerator.dev"
  validation_type   = "dns-txt-token"
}

resource "azurerm_dns_txt_record" "website_validation" {
  zone_name           = data.azurerm_dns_zone.cloudaccelerator.name
  resource_group_name = data.azurerm_dns_zone.cloudaccelerator.resource_group_name

  name = "_dnsauth"
  ttl  = 300

  record {
    value = azurerm_static_web_app_custom_domain.website.validation_token
  }
}
