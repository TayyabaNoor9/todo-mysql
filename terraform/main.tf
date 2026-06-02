terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "afc81c1a-7713-4702-8fba-2636260fe13c"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-taskapp-tayyaba"
  location = "Central India"
}

# Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "acrtaskapptayyaba"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# App Service Plan
resource "azurerm_service_plan" "plan" {
  name                = "asp-taskapp-tayyaba"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

# Backend App Service
resource "azurerm_linux_web_app" "backend" {
  name                = "app-taskapp-backend-tayyaba"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      docker_image_name        = "taskapp-backend:latest"
      docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
      docker_registry_username = azurerm_container_registry.acr.admin_username
      docker_registry_password = azurerm_container_registry.acr.admin_password
    }
  }

  app_settings = {
    DB_HOST       = azurerm_mssql_server.sql.fully_qualified_domain_name
    DB_NAME       = azurerm_mssql_database.db.name
    DB_USER       = "sqladmin"
    DB_PASSWORD   = "TaskApp@2024!"
    PORT          = "3001"
    WEBSITES_PORT = "3001"
  }
}

# SQL Server
resource "azurerm_mssql_server" "sql" {
  name                         = "sql-taskapp-tayyaba"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "TaskApp@2024!"
}

# SQL Firewall - Allow Azure Services
resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# SQL Database
resource "azurerm_mssql_database" "db" {
  name      = "db-taskapp"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "S0"
}

# Static Web App (East Asia - Central India not supported)
resource "azurerm_static_web_app" "frontend" {
  name                = "stapp-taskapp-tayyaba"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "eastasia"
  sku_tier            = "Free"
  sku_size            = "Free"
}