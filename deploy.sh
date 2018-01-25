#!/bin/bash -e

if [ $(whoami) != "root" ]; then
  source ~/.bash_profile
fi

npm run stage
terraform init ./terraform/rumble/
terraform plan -out .terraform/terraform.tfplan ./terraform/rumble/
