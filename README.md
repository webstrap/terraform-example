# terraform-example
 
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

## 0-INIT

This creates an S3 bucket for the following Terraform configurations to store the state in the cloud.
Usually terraform would create a local state file that is not shared with anyone else.

## 1-GLOBAL

When using one AWS account for stage and production, create shared users, and a root zone namespace
which is then used in each stage and production environment.


## TODO
 - Move most parts to modules
 - Move certificates from global to each environment
   - Prod should create as well a DNS nameserver part added to the global zone
 - Generate Database passwords via Terraform
