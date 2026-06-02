output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "backend_url" {
  value = azurerm_linux_web_app.backend.default_hostname
}

output "frontend_url" {
  value = azurerm_static_web_app.frontend.default_host_name
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.sql.fully_qualified_domain_name
}