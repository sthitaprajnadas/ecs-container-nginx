variable "name" {
  description = "The name for the Role"
  type        = string
}

variable "name_ecs_task_role" {
  description = "The name for the Ecs Task Role"
  type        = string
  default     = null
}

variable "create_ecs_role" {
  description = "Set this variable to true if you want to create a role for ECS"
  type        = bool
  default     = false
}


variable "create_policy" {
  description = "Set this variable to true if you want to create an IAM Policy"
  type        = bool
  default     = false
}

variable "attach_to" {
  description = "The ARN or role name to attach the policy created"
  type        = string
  default     = ""
}




