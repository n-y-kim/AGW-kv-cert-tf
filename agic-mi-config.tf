data "azurerm_resource_group" "mc_rg" {
  count = var.resource_count
  name = azurerm_kubernetes_cluster.k8s[count.index].node_resource_group
  depends_on = [ azurerm_resource_group.k8s-rg ]
}

data "azurerm_user_assigned_identity" "auto_created_agic_mi" {
  count = var.resource_count
  name  = "ingressapplicationgateway-${local.cluster_names[count.index]}"
  resource_group_name = data.azurerm_resource_group.mc_rg[count.index].name
}

resource "azurerm_role_assignment" "assign_contributor_agic" {
  count                = var.resource_count
  scope                = azurerm_application_gateway.network[count.index].id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.auto_created_agic_mi[count.index].principal_id
}

resource "azurerm_role_assignment" "assign_reader_appgw_rg" {
  count                = var.resource_count
  scope                = azurerm_resource_group.k8s-rg[count.index].id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_user_assigned_identity.auto_created_agic_mi[count.index].principal_id
}


# resource 'azurerm_user_assigned_identity' 'aks_managed_identity' {
#   name                = var.cluster_name
#   location            = var.location
#   resource_group_name = var.cluster_name
# }
 
# data 'azurerm_container_registry' 'acr' {    
#   name                = var.acr_info_map[var.env].name
#   resource_group_name = var.acr_info_map[var.env].resource_group_name
# }
 
# resource 'azurerm_role_assignment' 'acr_role_assignment' {
# azurerm_role_definition.module_role_definition.role_definition_resource_id
#   scope                    = data.azurerm_container_registry.acr.id
#   role_definition_name     = 'AcrPull'
#   principal_id             = azurerm_user_assigned_identity.aks_managed_identity.principal_id
# }

# resource "azurerm_role_assignment" "assign_contributor_mc_k8s_rg" {
#   scope = data.azurerm_resource_group.mc_rg.id
#   role_definition_name = "Contributor"
#   principal_id         = data.azurerm_user_assigned_identity.auto_created_agic_mi.principal_id

#   depends_on = [ azurerm_kubernetes_cluster.k8s ]
# }

# resource "azurerm_role_assignment" "assign_network_contributor_agic_rg" {
#   scope = azurerm_subnet.ingress-appgateway-subnet.id
#   role_definition_name = "Network Contributor"
#   principal_id         = data.azurerm_user_assigned_identity.auto_created_agic_mi.principal_id
# }

resource "azurerm_role_assignment" "agic_operator_role_assignment" {
  count = var.resource_count
  scope                = azurerm_user_assigned_identity.agic_identity[count.index].id
  role_definition_name = "Managed Identity Operator"
  principal_id         = data.azurerm_user_assigned_identity.auto_created_agic_mi[count.index].principal_id
}