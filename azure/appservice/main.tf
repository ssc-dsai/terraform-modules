
# ---------------------------------------------------------------------------------------------------------------------
# Azure Container Registry - Data
# ---------------------------------------------------------------------------------------------------------------------
data "azurerm_container_registry" "this" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
}

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

  tags = var.tags

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.this.instrumentation_key
    DOCKER_REGISTRY_SERVER_URL            = data.azurerm_container_registry.this.login_server
    DOCKER_REGISTRY_SERVER_USERNAME       = ""
    DOCKER_REGISTRY_SERVER_PASSWORD       = ""
    WEBSITE_WEBDEPLOY_USE_SCM             = true
 }

}