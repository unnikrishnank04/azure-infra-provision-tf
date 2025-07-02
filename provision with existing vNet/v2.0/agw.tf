data "azurerm_subnet" "public_subnet" {
  name                 = var.existing_public_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name_vnet
}

### Prerequisites:
# 1. **Create an Azure Key Vault**: Ensure the Azure Key Vault is created and reference its ID in the `key_vault_id` attribute for  `data` block.
# 2. **Grant Access to Terraform**: Assign `Get`, `Set`, and `List` permissions to the Azure Key Vault for the Terraform service principal, ensuring it has access to manage secrets.
# 3. **Store the Base64-Encoded PFX Certificate**: Add a secret to the Key Vault with the name `SSLCert`, containing the base64-encoded value of your PFX certificate.
# 4. **Store the SSL Certificate Password**: Add another secret named `SSLCertificatePass` in the Key Vault, storing the password for the SSL certificate.

 locals {
  key_vault_id = var.agw_key_vault
}

# Since the Application Gateway only supports UserAssigned identities
  resource "azurerm_user_assigned_identity" "agw_uai" {
  name                = "${var.agw_name}-user-assigned-identity"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  lifecycle {
    ignore_changes = [tags]
  }

}

# Public IP for Application Gateway
resource "azurerm_public_ip" "app_gw_ip" {
  name                = var.agw_pip_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle {
    ignore_changes = [tags]

  }
}

resource "azurerm_key_vault_access_policy" "grant_access_to_agw_users_assigned" {
  key_vault_id = local.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.agw_uai.principal_id # Getting Object ID of UserAssigned identities
  secret_permissions = ["Get"]
}


# Login to azure Portal and Store the passowrd
data "azurerm_key_vault_secret" "ssl_cert_password" {
  name         = "SSLPassword"
  key_vault_id = local.key_vault_id
}

# Use this command to stoare the SSL base64 -w 0 path/to/your-certificate.pfx > certificate_base64.txt
data "azurerm_key_vault_secret" "ssl_cert_secret" {
  name         = "SSLCertificate"
  key_vault_id = local.key_vault_id
}

resource "azurerm_web_application_firewall_policy" "waf_agw" {
  name                = var.awg_waf_policy_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location


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
      match_values = ["185.46.212.0/22", "104.129.192.0/20", "165.225.0.0/17", "165.225.192.0/18", "147.161.128.0/17", "136.226.0.0/16", "137.83.128.0/18", "167.103.0.0/16", "170.85.0.0/16", "194.9.112.0/22", "194.9.116.0/24", "87.58.64.0/18", "198.14.64.0/18", "101.2.192.0/18"]
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

# Application Gateway WAF
resource "azurerm_application_gateway" "app_gw" {
  name                = var.agw_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.agw_uai.id
    ]
  }

  gateway_ip_configuration {
    name      = "myAppGwIpConfig"
    subnet_id = data.azurerm_subnet.public_subnet.id
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "front-end-pip"
    public_ip_address_id = azurerm_public_ip.app_gw_ip.id
  }

  backend_address_pool {
    name = "front-end-pool"#"backendAddressPool1"
      fqdns = [
      for web_app_name in var.selected_web_apps_front_end :
      azurerm_linux_web_app.app_service[web_app_name].default_hostname
    ]
  }

  backend_address_pool {
    name = "back-end-api-pool"#"backendAddressPool1"
      fqdns = [
      for web_app_name in var.selected_web_apps_backed_end :
      azurerm_linux_web_app.app_service[web_app_name].default_hostname
    ]
  }

  backend_http_settings {
    name                                = "front-end-pool-setting"#"httpSettings"
    cookie_based_affinity               = "Disabled"
    path                                = "/"
    port                                = 443 # The port on which the backend host are listening on
    protocol                            = "Https" # Backedn server
    probe_name                          = "front-end-pool-health-probe"
    pick_host_name_from_backend_address = true
    request_timeout                     = 20
  }

  backend_http_settings {
    name                                = "back-end-api-pool-setting"#"httpSettings"
    cookie_based_affinity               = "Disabled"
    path                                = ""
    port                                = 443 # The port on which the backend host are listening on
    protocol                            = "Https" # Backedn server
    probe_name                          = "back-end-api-pool-health-probe"
    pick_host_name_from_backend_address = true
    request_timeout                     = 20
  }

    probe {
    name                                      = "back-end-api-pool-health-probe"
    protocol                                  = "Https"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 10
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = [200]
    }
  }

    ssl_certificate {
    name                 = "${var.agw_name}-ssl-cert"
    data                 = data.azurerm_key_vault_secret.ssl_cert_secret.value
    password             = data.azurerm_key_vault_secret.ssl_cert_password.value
  }

/*
  ssl_policy {
    policy_type                = "Custom"
    min_protocol_version       = "TLSv1_2"

    cipher_suites = [
      "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
      "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
      "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384",
      "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256",
      "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA",
      "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA",
      "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384",
      "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256",
      "TLS_DHE_RSA_WITH_AES_256_CBC_SHA",
      "TLS_DHE_RSA_WITH_AES_128_CBC_SHA",
      "TLS_RSA_WITH_AES_256_GCM_SHA384",
      "TLS_RSA_WITH_AES_128_GCM_SHA256",
      "TLS_RSA_WITH_AES_256_CBC_SHA256",
      "TLS_RSA_WITH_AES_128_CBC_SHA256",
      "TLS_RSA_WITH_AES_256_CBC_SHA",
      "TLS_RSA_WITH_AES_128_CBC_SHA",
      "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
      "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
      "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384",
      "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256",
      "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA",
      "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA",
      "TLS_DHE_DSS_WITH_AES_256_CBC_SHA256",
      "TLS_DHE_DSS_WITH_AES_128_CBC_SHA256",
      "TLS_DHE_DSS_WITH_AES_256_CBC_SHA",
      "TLS_DHE_DSS_WITH_AES_128_CBC_SHA",
      "TLS_RSA_WITH_3DES_EDE_CBC_SHA",
      "TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA"
    ]
  }
*/  
  ssl_policy {
    policy_type                = "CustomV2"
    min_protocol_version       = "TLSv1_3"
  }

  http_listener {
    name                           = "443Listener"
    frontend_ip_configuration_name = "front-end-pip"
    frontend_port_name             = "https-port"
    protocol                       = "Https"
    ssl_certificate_name           = "${var.agw_name}-ssl-cert"
  }

    probe {
    name                                      = "front-end-pool-health-probe"
    protocol                                  = "Https"
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
    default_backend_address_pool_name  = "front-end-pool" 
    default_backend_http_settings_name = "front-end-pool-setting"

    path_rule {
      # Name of the rules
      name                       = "api-path-rule"
      paths                      = ["/api*"]
      backend_address_pool_name   = "back-end-api-pool"
      backend_http_settings_name  = "back-end-api-pool-setting"
    }
  }

  request_routing_rule {
    name                       = "incoming-traffic-routing-rule-01"
    rule_type                  = "PathBasedRouting"
    http_listener_name         = "443Listener"
    url_path_map_name          = "backend-api-path-url"
    priority                   = 5
  }

  lifecycle {
    ignore_changes = [tags]

  }

  depends_on         = [azurerm_public_ip.app_gw_ip, azurerm_linux_web_app.app_service]
  firewall_policy_id = azurerm_web_application_firewall_policy.waf_agw.id

}