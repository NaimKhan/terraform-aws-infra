# IAM Module

Least-privilege IAM roles for ECS. Two separate roles, two separate purposes:

- **Task Execution Role** — used by the ECS agent (pulls image from ECR,
  writes logs, fetches secrets at container startup). Uses AWS's managed
  `AmazonECSTaskExecutionRolePolicy`.
- **Task Role** — assumed by your application code at runtime. Starts with
  zero permissions beyond an example secrets-read policy; extend per project.

Keeping these separate is a security best practice — the ECS agent's
permissions should never be the same as the application's runtime permissions.

## Outputs
| Name | Description |
|---|---|
| ecs_task_execution_role_arn | Passed into the ECS task definition (`execution_role_arn`) |
| ecs_task_role_arn | Passed into the ECS task definition (`task_role_arn`) |
