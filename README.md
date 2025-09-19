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



