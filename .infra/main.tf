locals {
  service_prefix = "pwdgame"
}

terraform {
  backend "azurerm" {
    container_name = "tfstate"
    key            = "pwdgame-state"
    # Remaining parameters from '-backend-config' arguments
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.55.0"
    }
  }
}

provider "azurerm" {
  features {}
  environment = var.azure_environment
  # Service principal credential from env variables
}

resource "random_string" "service_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create Resource Group
resource "azurerm_resource_group" "main_rg" {
  name     = var.azure_resource_group_name
  location = var.azure_region
}

resource "azurerm_app_service_plan" "main_plan" {
  name                = "${local.service_prefix}-apps-${random_string.service_suffix.id}"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "cat_game" {
  name                = "${local.service_prefix}-cat-game-${random_string.service_suffix.id}"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  app_service_plan_id = azurerm_app_service_plan.main_plan.id
  https_only          = true
}

output "cat_game_app_service_name" {
  value = azurerm_app_service.cat_game.name
}