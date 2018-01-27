#!/bin/bash -e

if [ $(whoami) != "root" ]; then
  source ~/.bash_profile
fi

npm run stage
if [[ -d ./terraform ]]; then
  echo 'Already initialized terraform.'
else
  terraform init ./terraform/rumble/
fi
terraform plan -out .terraform/terraform.tfplan ./terraform/rumble/
