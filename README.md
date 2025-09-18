# Terraform Example
 
### Setup

- Go into each folders variables.tf and adjust it to your project
- Terraform Cli: [Install](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- AWS Cli: [Install](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
  Create the following 2 files
  - **~/.aws/credentials**
    ```bash
    [example-profile]
    aws_access_key_id = xxxxxx
    aws_secret_access_key = xxxxxxxxx
    ```
  - ~/.aws/config
     ```bash
     [profile example-profile]
     region = eu-central-1
     output = json
     ```

Use AWS profiles to manage credentials for different AWS accounts
Restrict allowed AWS accounts

## 0-INIT

- Creates S3 bucket for remote state storage with KMS encryption
- Sets up DynamoDB table for state locking
- Configured for eu-central-1 region

## 1-GLOBAL

- Manages Route53 DNS zones, IAM users, groups, and policies
- Creates SSL certificates
- Stores state as global.terraform.tfstate
- Serves as the foundation for environment-specific deployments

## 2-STAGE
- Contains staging environment infrastructure
- Includes VPC, EC2, load balancers, security groups
- Has API services, S3 configurations, and WireGuard VPN
- References global state for shared resources


