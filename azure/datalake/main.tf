# ---------------------------------------------------------------------------------------------------------------------
# Data
# ---------------------------------------------------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

# ---------------------------------------------------------------------------------------------------------------------
# Creating Azure Storage Account
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_storage_account" "this" {
  name                      = var.name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_tier              = var.account_tier
  account_replication_type  = var.account_replication_type
  account_kind              = var.account_kind
  allow_blob_public_access  = var.allow_blob_public_access
  enable_https_traffic_only = true
  min_tls_version           = var.min_tls_version

  network_rules {
    default_action="Deny"
  }

  queue_properties {
     logging {
        delete                = true
        read                  = true
        write                 = true
        version               = "1.0"
        retention_policy_days = 10
    }
  }

  tags = var.tags
}


# ---------------------------------------------------------------------------------------------------------------------
# Creating Azure Storage Account Container
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_storage_container" "ok_container" {
  name                  = "default"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

# ---------------------------------------------------------------------------------------------------------------------
# Store the Storage Account access key in Azure Key Vault
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_key_vault_secret" "this" {
  name         = var.access_key_secret_name
  value        = azurerm_storage_account.this.primary_access_key
  key_vault_id = var.key_vault_id
  expiration_date = timeadd(timestamp(), "17520h") # expires in 2 years
  content_type = "text/plain"
}

# ---------------------------------------------------------------------------------------------------------------------
# Store the current Subscription ID in Azure Key Vault
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_key_vault_secret" "subscription_id_secret_name" {
  name         = var.subscription_id_secret_name
  value        = data.azurerm_client_config.current.subscription_id
  key_vault_id = var.key_vault_id
  expiration_date = timeadd(timestamp(), "17520h") # expires in 2 years
  content_type = "text/plain"
}

# ---------------------------------------------------------------------------------------------------------------------
# Store the current Tenant ID in Azure Key Vault
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_key_vault_secret" "tenant_id_secret_name" {
  name         = var.tenant_id_secret_name
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = var.key_vault_id
  expiration_date = timeadd(timestamp(), "17520h") # expires in 2 years
  content_type = "text/plain"
}

# ---------------------------------------------------------------------------------------------------------------------
# Azure Storage Accounts use customer-managed key for encryption
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_storage_account_customer_managed_key" "this" {
  storage_account_id = azurerm_storage_account.this.id
  key_vault_id       = var.key_vault_id
  key_name           = var.key_vault_name
}