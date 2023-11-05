
# ------- Providers -------
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

provider "docker" {

}

# ------- Networking -------
module "networking" {
  source = "./Modules/Networking"
  cidr   = ["10.120.0.0/16"]
  name   = var.environment_name
}

# ------- Creating Target Group for the ALB blue environment -------
module "target_group_blue" {
  source              = "./Modules/ALB"
  create_target_group = true
  name                = "tg-${var.environment_name}-blue"
  port                = 80
  protocol            = "HTTP"
  vpc                 = module.networking.aws_vpc
  tg_type             = "ip"
  health_check_path   = "/status"
  health_check_port   = var.port_app
}

# ------- Creating Target Group for the  ALB green environment -------
module "target_group_green" {
  source              = "./Modules/ALB"
  create_target_group = true
  name                = "tg-${var.environment_name}-green"
  port                = 80
  protocol            = "HTTP"
  vpc                 = module.networking.aws_vpc
  tg_type             = "ip"
  health_check_path   = "/status"
  health_check_port   = var.port_app
}


# ------- Creating Security Group for the ALB -------
module "security_group_alb" {
  source              = "./Modules/SecurityGroup"
  name                = "alb-${var.environment_name}"
  description         = "Controls access to the ALB"
  vpc_id              = module.networking.aws_vpc
  cidr_blocks_ingress = ["0.0.0.0/0"]
  ingress_port        = 80
}


# ------- Creating Application ALB -------
module "alb" {
  source         = "./Modules/ALB"
  create_alb     = true
  name           = "${var.environment_name}"
  subnets        = [module.networking.public_subnets[0], module.networking.public_subnets[1]]
  security_group = module.security_group_alb.sg_id
  target_group   = module.target_group_blue.arn_tg
}



# ------- ECS Role -------
module "ecs_role" {
  source             = "./Modules/IAM"
  create_ecs_role    = true
  name               = var.iam_role_name["ecs"]
  name_ecs_task_role = var.iam_role_name["ecs_task_role"]
}

# ------- Creating a IAM Policy for role -------
module "ecs_role_policy" {
  source        = "./Modules/IAM"
  name          = "ecs-${var.environment_name}"
  create_policy = true
  attach_to     = module.ecs_role.name_role
}


# ------- Creating ECS Task Definition for the  -------
module "ecs_taks_definition" {
  source             = "./Modules/ECS/TaskDefinition"
  name               = "${var.environment_name}"
  container_name     = var.container_name
  execution_role_arn = module.ecs_role.arn_role
  task_role_arn      = module.ecs_role.arn_role_ecs_task_role
  cpu                = 256
  memory             = "512"
  docker_repo        = var.docker_image_repo
  region             = var.aws_region
  container_port     = var.port_app
}

# ------- Creating a  Security Group for ECS TASKS -------
module "security_group_ecs_task" {
  source          = "./Modules/SecurityGroup"
  name            = "ecs-task-${var.environment_name}"
  description     = "Controls access to the  ECS task"
  vpc_id          = module.networking.aws_vpc
  ingress_port    = var.port_app
  security_groups = [module.security_group_alb.sg_id]
}

# ------- Creating ECS Cluster -------
module "ecs_cluster" {
  source = "./Modules/ECS/Cluster"
  name   = var.environment_name
}

# ------- Creating ECS Service  -------
module "ecs_service" {
  depends_on          = [module.alb]
  source              = "./Modules/ECS/Service"
  name                = "${var.environment_name}"
  desired_tasks       = 1
  arn_security_group  = module.security_group_ecs_task.sg_id
  ecs_cluster_id      = module.ecs_cluster.ecs_cluster_id
  arn_target_group    = module.target_group_blue.arn_tg
  arn_task_definition = module.ecs_taks_definition.arn_task_definition
  subnets_id          = [module.networking.private_subnets[0], module.networking.private_subnets[1]]
  container_port      = var.port_app
  container_name      = var.container_name
}


# ------- Creating ECS Autoscaling policies for the application -------
module "ecs_autoscaling" {
  depends_on   = [module.ecs_service]
  source       = "./Modules/ECS/Autoscaling"
  name         = "${var.environment_name}"
  cluster_name = module.ecs_cluster.ecs_cluster_name
  min_capacity = 1
  max_capacity = 4
}


# ------- Creating a SNS topic -------
module "sns" {
  source   = "./Modules/SNS"
  sns_name = "sns-${var.environment_name}"
}

