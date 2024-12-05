variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "resource_group_location" {
  description = "The location of the resource group"
  type        = string
}

variable "resource_header" {
  description = "The Header of the resource name"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The id of the analytics workspace"
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "The name of the analytics workspace"
  type        = string
}
