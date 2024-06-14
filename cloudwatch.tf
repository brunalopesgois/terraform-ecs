# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "profile-service_log_group" {
  name              = "/ecs/profile-service"
  retention_in_days = 30

  tags = {
    Name = "cw-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "profile-service_log_stream" {
  name           = "profile-service-log-stream"
  log_group_name = aws_cloudwatch_log_group.profile-service_log_group.name
}
