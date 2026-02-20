variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "docker_image" {
  type    = string
  default = "035736213603.dkr.ecr.ap-south-1.amazonaws.com/my-app:latest"
}

# Minimal desired count for lowest cost
variable "ecs_desired_count" {
  type    = number
  default = 1
}

# Minimal Fargate CPU and Memory
variable "ecs_task_cpu" {
  type    = string
  default = "256"   # 0.25 vCPU
}

variable "ecs_task_memory" {
  type    = string
  default = "512"   # 0.5 GB
}
