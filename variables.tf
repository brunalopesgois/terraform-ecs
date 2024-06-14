variable "az_count" {
  default     = "2"
  description = "number of availability zones in above region"
}

variable "ecs_task_execution_role" {
  default     = "ecsTaskExecutionRole"
  description = "ECS task execution role name"
}

variable "app_name" {
  default     = "hello-service"
  description = "docker image to run in this ECS cluster"
}

variable "app_port" {
  default     = "80"
  description = "portexposed on the docker image"
}

variable "app_count" {
  default     = "2" #choose 2 bcz i have choosen 2 AZ
  description = "numer of docker containers to run"
}

variable "health_check_path" {
  default = "/api"
}

variable "fargate_cpu" {
  default     = "2048"
  description = "fargate instacne CPU units to provision,my requirent 1 vcpu so gave 1024"
}

variable "fargate_memory" {
  default     = "4096"
  description = "Fargate instance memory to provision (in MiB) not MB"
}

variable "profile-tskd" {
  description = "Task definition of profile-service"
  default = [
    {
      name        = "hello-service"
      image       = "286608068884.dkr.ecr.us-east-1.amazonaws.com/hello-service"
      essential   = true
      networkMode = "awsvpc"
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/profile-service"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      environment = [
        {
          name  = "PORT"
          value = "80"
        }
      ]
    }
  ]
}

