# Ecommerce Azure Terraform

Run:

terraform init
terraform plan -var-file=envs/prod.tfvars
terraform apply -var-file=envs/prod.tfvars -auto-approve
