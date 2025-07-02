
locals {
  key_vault_id = var.agw_key_vault
}

# Since the Application Gateway only supports UserAssigned identities
  resource "azurerm_user_assigned_identity" "AppGateway_uai" {
  name                = "${var.AppGateway_name}-user-assigned-identity"
  resource_group_name = var.resource_group
  location            = var.location
  lifecycle {
    ignore_changes = [tags]
  }

}

#Frontend IP
resource "azurerm_public_ip" "Frontend-PIP" {
  name                = var.frontend_public_IP_name
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_dev.location
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_dev.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_key_vault_access_policy" "grant_access_to_agw_users_assigned" {
  key_vault_id = local.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.AppGateway_uai.principal_id # Getting Object ID of UserAssigned identities
  secret_permissions = ["Get"]
}

/*
# Login to azure Portal and Store the passowrd
data "azurerm_key_vault_secret" "ssl_cert_password" {
  name         = "SSLPassword"
  key_vault_id = local.key_vault_id
}
*/


resource "azurerm_web_application_firewall_policy" "waf_agw" {
  name                = var.AppGateway_WAF_Policy_name
  resource_group_name = var.resource_group
  location            = var.location
 # api_version = "2021-03-01"
  depends_on = [azurerm_resource_group.KnowledgeAssist_dev, azurerm_virtual_network.CKA-Vnet ]


# Rule to allow specific IP addresses
  custom_rules {
    name      = "AllowZScalerIPs"
    priority  = 5
    rule_type = "MatchRule"
    action    = "Allow"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }

      operator     = "IPMatch"
      match_values = ["185.46.212.0/22", "104.129.192.0/20", "165.225.0.0/17"]
    }
  }

  # Default deny rule for all other traffic
  custom_rules {
    name      = "DenyAllOther"
    priority  = 10
    rule_type = "MatchRule"
    action    = "Block"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }

      operator     = "IPMatch"
      match_values = ["0.0.0.0/0"]  # Block all other IPs
    }
  }

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
      rule_group_override {
        rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
        rule {
          id      = "920300"
          enabled = true
          action  = "Log"
        }

        rule {
          id      = "920440"
          enabled = true
          action  = "Block"
        }
      }
    }
 
  }

  lifecycle {
    ignore_changes = [tags]

  }
  
}

resource "azurerm_application_gateway" "App-Gateway-network" {
  name                = var.AppGateway_name #"AppGateway-CKA-dev"
  resource_group_name = var.resource_group #azurerm_resource_group.KnowledgeAssist_V2_dev.name
  location            = var.location #azurerm_resource_group.KnowledgeAssist_V2_dev.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.AppGateway_uai.id
    ]
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = azurerm_subnet.Pub-Sub1-App-Gateway.id
  }

  frontend_port {
    name = "frontendport"
    port = 80
  } 

  frontend_ip_configuration {
    name                 = "frontendIP_Config"
    public_ip_address_id = azurerm_public_ip.Frontend-PIP.id
  }

  backend_address_pool {
    name = "frontend-pool" #backend address pool1
    fqdns = [
      for web_app in var.frontend_pool_webapp_name:
      azurerm_linux_web_app.app_service[web_app].default_hostname
        ]
  }

  backend_address_pool {
    name = "backend-api-pool"#"backendAddressPool1"
    fqdns = [
      for web_app in var.backend_pool_webapp_name:
      azurerm_linux_web_app.app_service[web_app].default_hostname
    ]
  }

    backend_http_settings {
    name                  = "frontend_pool_https_settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    probe_name            = "frontend_pool_health_probe"
    pick_host_name_from_backend_address = true
    request_timeout       = 30
  }

  backend_http_settings {
    name                  = "backend_pool_https_settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    probe_name            = "backend_api_pool_health_probe"
    pick_host_name_from_backend_address = true
    request_timeout       = 30
  }
    probe {
    name                                      = "backend_api_pool_health_probe"
    protocol                                  = "Http"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 10
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = [200]
    }
  }

/*
    ssl_certificate {
    name                 = "${var.AppGateway_name}-ssl-cert"
    data                 = data.azurerm_key_vault_secret.ssl_cert_secret.value
    password             = data.azurerm_key_vault_secret.ssl_cert_password.value
  }

  ssl_policy {
    policy_type                = "CustomV2"
    min_protocol_version       = "TLSv1_3"
  }*/

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontendIP_Config"
    frontend_port_name             = "frontendport"
    protocol                       = "Http"
  }
    probe {
    name                                      = "frontend_pool_health_probe"
    protocol                                  = "Http"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 10
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = [200]
    }
  }

  # Enable Path based routing
  url_path_map {
    name                       = "backend-api-path-url"
	# It specifies the default backend pool to which traffic is routed if no specific path-based rule matches the incoming request
    default_backend_address_pool_name  = "frontend-pool" 
    default_backend_http_settings_name = "frontend_pool_https_settings"

    path_rule {
      # Name of the rules
      name                       = "api-path-rule"
      paths                      = ["/api*"]
      backend_address_pool_name   = "backend-api-pool"
      backend_http_settings_name  = "backend_pool_https_settings"
    }
  }

request_routing_rule {
    name                       = "incoming-traffic-routing-rule-01"
    rule_type                  = "PathBasedRouting"
    http_listener_name         = "http-listener"
    url_path_map_name          = "backend-api-path-url"
    priority                   = 5
}

/*
  request_routing_rule {
    name                       = "RoutingRule1"
    rule_type                  = "PathBasedRouting"
    priority                   = 25
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-api-path-url"
    backend_http_settings_name = "backend_pool_https_settings"
  }*/

  lifecycle {
    ignore_changes = [tags]
  }
  firewall_policy_id = azurerm_web_application_firewall_policy.waf_agw.id
}
