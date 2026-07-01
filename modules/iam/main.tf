locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

# ---------------------------------------------------------------------------
# ECS Task EXECUTION role — used by the ECS agent itself to:
#   - pull the image from ECR
#   - write logs to CloudWatch
#   - fetch secrets from Secrets Manager / SSM Parameter Store
# This is NOT the role your application code runs as.
# ---------------------------------------------------------------------------
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_managed" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ---------------------------------------------------------------------------
# ECS Task role — this is the identity your APPLICATION CODE assumes at
# runtime. Give it least-privilege permissions for whatever AWS services
# your app actually calls (S3, SSM, Secrets Manager, etc). Empty by default;
# attach extra policies per project as needed.
# ---------------------------------------------------------------------------
resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

# Example least-privilege inline policy: allow reading app secrets only.
# Extend/replace this per real project needs.
resource "aws_iam_role_policy" "ecs_task_secrets_read" {
  name = "${var.project_name}-${var.environment}-ecs-task-secrets-read"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "ssm:GetParameter",
        "ssm:GetParameters"
      ]
      Resource = "arn:aws:secretsmanager:*:*:secret:${var.project_name}-${var.environment}-*"
    }]
  })
}
