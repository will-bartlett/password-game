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
      version = "~>=3.48.0"
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

resource "azurerm_application_insights" "main_ai" {
  name                = "${local.service_prefix}-ai-${random_string.service_suffix.id}"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  application_type    = "web"
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
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "cat_game" {
  name                = "${local.service_prefix}-cat-game-${random_string.service_suffix.id}"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  app_service_plan_id = azurerm_app_service_plan.main_plan.id
  https_only          = true
  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.main_ai.instrumentation_key
  }
}

resource "azurerm_app_service" "dog_game" {
  name                = "${local.service_prefix}-dog-game-${random_string.service_suffix.id}"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  app_service_plan_id = azurerm_app_service_plan.main_plan.id
  https_only          = true
  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.main_ai.instrumentation_key
  }
}

resource "azurerm_function_app" "backend_api" {
  name                       = "${local.service_prefix}-backend-api-${random_string.service_suffix.id}"
  location                   = azurerm_resource_group.main_rg.location
  resource_group_name        = azurerm_resource_group.main_rg.name
  app_service_plan_id        = azurerm_app_service_plan.main_plan.id
  storage_account_name       = azurerm_storage_account.main_storage.name
  storage_account_access_key = azurerm_storage_account.main_storage.primary_access_key
  os_type                    = "linux"
  https_only                 = true
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"       = "node",
    "NODE_ENV"                       = "production",
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.main_ai.instrumentation_key
    "StorageAccountConnectionString" = azurerm_storage_account.main_storage.primary_connection_string
    "SignalRConnectionString"        = azurerm_signalr_service.chat_service.primary_connection_string
  }
  site_config {
    always_on        = true
    linux_fx_version = "node|14-lts"
    cors {
      allowed_origins = [
        "https://${azurerm_app_service.cat_game.default_site_hostname}",
        "https://${azurerm_app_service.dog_game.default_site_hostname}",
      ]
      support_credentials = true
    }
  }
  version = "~3"
}

resource "azurerm_signalr_service" "chat_service" {
  name                = "${local.service_prefix}-signalr-${random_string.service_suffix.id}"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name

  sku {
    name     = "Free_F1"
    capacity = 1
  }

  cors {
    allowed_origins = [
      "https://${azurerm_app_service.cat_game.default_site_hostname}",
      "https://${azurerm_app_service.dog_game.default_site_hostname}",
    ]
  }

  features {
    flag  = "ServiceMode"
    value = "Serverless"
  }
}

output "app_insights_instrumentation_key" {
  value     = azurerm_application_insights.main_ai.instrumentation_key
  sensitive = true
}

output "cat_game_app_service_name" {
  value = azurerm_app_service.cat_game.name
}

output "dog_game_app_service_name" {
  value = azurerm_app_service.dog_game.name
}

output "backend_api_func_app_name" {
  value = azurerm_function_app.backend_api.name
}

output "backend_api_func_app_hostname" {
  value = azurerm_function_app.backend_api.default_hostname
}
