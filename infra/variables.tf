variable "aws_profile" {
  description = "The profile name that you have configured in the file .aws/credentials"
  type        = string
}

variable "aws_region" {
  description = "The AWS Region in which you want to deploy the resources"
  type        = string
}

variable "environment_name" {
  description = "The name of your environment(PROD/DEV/STAGE)"
  type        = string

  validation {
    condition     = length(var.environment_name) < 23
    error_message = "Due the this variable is used for concatenation of names of other resources, the value must have less than 23 characters."
  }
}

variable "docker_image_repo" {
  description = "Dockerhub image repo"
  type        = string
  default     = "nginxdemos/hello"
}

variable "port_app" {
  description = "The port used by your application"
  type        = number
  default     = 80
}

variable "container_name" {
  description = "The name of the container of each ECS service"
  type        = string
  default = "Container-app"
}

variable "iam_role_name" {
  description = "The name of the IAM Role for each service"
  type        = map(string)
  default = {
    ecs           = "ECS-task-excecution-Role"
    ecs_task_role = "ECS-task-Role"
  }
}
