resource "aws_ecs_cluster" "unionaudio-backend-cluster" {
  name = "union-audio-backend"
}

resource "aws_ecs_task_definition" "profile-tskd" {
  family                   = "profile-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = jsonencode(var.profile-tskd)
}

resource "aws_ecs_service" "profile-service" {
  name            = "profile-service"
  cluster         = aws_ecs_cluster.unionaudio-backend-cluster.id
  task_definition = aws_ecs_task_definition.profile-tskd.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = aws_subnet.unionaudio-backend-private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.unionaudio-backend-tg.arn
    container_name   = var.app_name
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.unionaudio-backend-alb-listener, aws_iam_role_policy_attachment.ecs_task_execution_role]
}
