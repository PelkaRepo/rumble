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

if [[ -z $1 ]]; then
  echo -p 'Please enter phone numbers to have as default subscribers, as a standard list, e.g.,  ["1-888-888-8888","1-888-888-8888"]: '
  read PHONE_NUMS
else
  echo 'Setting default subscribers based on headless input...'
  PHONE_NUMS=$1
fi

terraform plan -var "subscribers=${PHONE_NUMS}" -out .terraform/terraform.tfplan ./terraform/rumble/
