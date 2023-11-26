# tf-backend
Terraform / OpenTofu AWS S3 backend module with DynamoDB for lock file. 

## Prerequisites

Ensure aws api credentials are in `~/.aws/credentials`
```
[default]
aws_access_key_id = AWS_ACCESS_KEY_ID
aws_secret_access_key = AWS_SECRET_ACCESS_KEY
```
or as env `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

## Usage

Using AWS S3 as a backend requires a 4-step process.
1. Replace REGION and PROJECT_NAME in `example.main.tf`
    ```bash
    REGION=eu-west-2 && 
    PROJECT_NAME=tf-backend && 
    sed "s/REGION/$REGION/g; s/PROJECT_NAME/$PROJECT_NAME/g" main.tf.template > main.tf
    ```

1. Create resources with local tfstate with `tofu init && tofu apply`.
2. Uncomment terraform backend "s3" block.
3. Run `tofu init` to switch to S3 backend.

## Destruction
Removing all resources is again a 4-step process.
1. Comment out terraform backend "s3" block.
2. Run `tofu init -migrate-state` to switch to local backend.
3. Comment out `prevent-destroy = true` in the bucket block.
3. Run `tofu destroy -auto-approve` to retire resources.
