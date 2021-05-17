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

resource "azurerm_storage_account" "main_storage" {
  name                     = "${local.service_prefix}stg${random_string.service_suffix.id}"
  location                 = azurerm_resource_group.main_rg.location
  resource_group_name      = azurerm_resource_group.main_rg.name
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"
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

resource "azurerm_function_app" "backend_api" {
  name                       = "${local.service_prefix}-backend-api-${random_string.service_suffix.id}"
  location                   = azurerm_resource_group.main_rg.location
  resource_group_name        = azurerm_resource_group.main_rg.name
  app_service_plan_id        = azurerm_app_service_plan.main_plan.id
  storage_account_name       = azurerm_storage_account.main_storage.name
  storage_account_access_key = azurerm_storage_account.main_storage.primary_access_key
  os_type                    = "linux"
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"       = "1",
    "FUNCTIONS_WORKER_RUNTIME"       = "node",
    "NODE_ENV"                       = "production",
    "StorageAccountConnectionString" = azurerm_storage_account.main_storage.primary_connection_string
  }
  site_config {
    always_on                 = true
    linux_fx_version          = "node|lts"
    use_32_bit_worker_process = true
    cors {
      allowed_origins = [azurerm_app_service.cat_game.default_site_hostname]
    }
  }
  version = "~3"
}

output "cat_game_app_service_name" {
  value = azurerm_app_service.cat_game.name
}

output "backend_api_func_app_name" {
  value = azurerm_function_app.backend_api.name
}

output "backend_api_func_app_hostname" {
  value = azurerm_function_app.backend_api.default_hostname
}