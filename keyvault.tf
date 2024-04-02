resource "azurerm_key_vault" "example" {
    count = var.resource_count
    name                        = "agw-kv-${count.index}"
    location                    = var.rg-location
    resource_group_name         = azurerm_resource_group.k8s-rg[count.index].name
    enabled_for_disk_encryption = true
    tenant_id                   = "16b3c013-d300-468d-ac64-7eda0820b6d3"
    soft_delete_retention_days  = 7
    purge_protection_enabled    = false

    sku_name = "standard"

    enable_rbac_authorization = true
}

resource "azurerm_key_vault_certificate" "upload-cert" {
    count        = var.resource_count
    name         = "test-cert"
    key_vault_id = azurerm_key_vault.example[count.index].id

    certificate {
        contents = filebase64("test-cert.pfx")
        password = "test"
    }
}