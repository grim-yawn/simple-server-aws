# Simple server

## Terraform

### Safety
All secret should be set via ENV or in files named `.auto.tfvars` which will be excluded from version control.
You need to setup aws profile with name "terraform"

### Backend
This configuration uses aws s3 bucket to store, first thing to do:
```shell
# Create file with secrets `.auto.tfvars`

# Inside ./terraform/backend
terraform init
# If backend bucket already exists this will be no-op run
terraform plan
terraform apply
```

### Main configuration
Due to terraform limitations you can't use variables inside backend configuration
```shell
# Inside ./terraform
terraform init
```

```shell
terraform plan
terraform apply
```
