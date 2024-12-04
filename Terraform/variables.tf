variable "provider_credentials" {
  type = object({
    subscription_id  = string
    tenant_id        = string
    sp_client_id     = string
    sp_client_secret = string
  })
}

variable "resource_group_config" {
  type = object({
    name             = string
    location         = string
  })
}
