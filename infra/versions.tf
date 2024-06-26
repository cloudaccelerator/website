terraform {
  required_version = "~> 1.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.9"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tf-backend"
    storage_account_name = "cloudacctfbackend"
    container_name       = "tfstate"
    key                  = "website.tfstate"
    use_azuread_auth     = true
    use_oidc             = true
  }
}
