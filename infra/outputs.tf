
output "app_endpoint" {
  value       = "${module.alb.dns_alb}"
  description = "Copy to your browser in order to access the app"
}