# ECR Module

Private Docker image registry used to store the application's container images
before ECS pulls them.

## What this module creates
- ECR repository with vulnerability scan-on-push enabled
- Lifecycle policy that auto-expires old images beyond a configurable count

## Inputs
| Name | Type | Description |
|---|---|---|
| project_name | string | Prefix for repo name |
| environment | string | dev / qa / prod |
| image_tag_mutability | string | MUTABLE / IMMUTABLE |
| max_image_count | number | Images retained before auto-expiry |

## Outputs
| Name | Description |
|---|---|
| repository_url | Used by CI/CD to push images, and by ECS task def to pull |
