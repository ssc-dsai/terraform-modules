
# ---------------------------------------------------------------------------------------------------------------------
# Azure Container Registry - Data
# ---------------------------------------------------------------------------------------------------------------------
data "azurerm_container_registry" "this" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
}

# data "azurerm_storage_account" "this" {
#   name                = var.storage_account_name
#   resource_group_name = var.resource_group_name
# }

# ---------------------------------------------------------------------------------------------------------------------
# Creating Application Insights
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_application_insights" "this" {
  name                = var.application_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = var.application_type

  tags                = var.tags

}

# ---------------------------------------------------------------------------------------------------------------------
# Creating Azure App Service Plan
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_app_service_plan" "this" {
  name                = var.service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = var.kind
  reserved            = true

  sku {
   tier     = "Standard"
   size     = "B2"
  }
  
  tags                = var.tags

}

# ---------------------------------------------------------------------------------------------------------------------
# Creating Azure App Service
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_app_service" "this" {
  name                = var.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.this.id
  https_only          = true
  client_cert_enabled = true

  tags = var.tags

  auth_settings {
    enabled = true
  }

  logs {
    detailed_error_messages_enabled = true
    failed_request_tracing_enabled = true
    http_logs {
      retention_in_days = 4
      retention_in_mb = 10
    }
  }

  identity {
    type = "SystemAssigned"
  }

  site_config {
    http2_enabled = true
    ftps_state = "Disabled"
  }

  #TODO: create variables
  site_config {
    dotnet_framework_version = "v5.0"
    http2_enabled = true
    ftps_state = "Disabled"
    scm_type  = "GitHub"
    always_on = "true"
    linux_fx_version  = "DOCKER|<arc01.azurecr.io/myapp:latest>"
    health_check_path = "/v1/heartbeat"
 }

 storage_account {
   name = "test_name"
   type = "AzureFiles"
  #  account_name = data.azurerm_storage_account.this.name
  #  share_name = "" # Container name
  #  access_key = "" # Access key for the storage account
 }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.this.instrumentation_key
    DOCKER_REGISTRY_SERVER_URL            = data.azurerm_container_registry.this.login_server
    DOCKER_REGISTRY_SERVER_USERNAME       = ""
    DOCKER_REGISTRY_SERVER_PASSWORD       = ""
    WEBSITE_WEBDEPLOY_USE_SCM             = true
 }

}