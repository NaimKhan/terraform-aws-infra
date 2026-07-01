# Bootstrap

Run this ONCE, before touching dev/qa/prod. It creates the shared S3 bucket
(versioned, encrypted, private) and DynamoDB table that every environment's
`backend.tf` points at for remote state storage and locking.

Uses a **local** backend on purpose — it's the thing that creates the
remote backend, so it can't depend on the remote backend existing yet.

## Usage
```bash
cd environments/bootstrap
terraform init
terraform apply
```

After this succeeds, `dev`, `qa`, and `prod` can all run `terraform init`
against the S3 bucket + DynamoDB table created here.
