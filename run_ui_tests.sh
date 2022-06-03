#!/bin/bash
# Usage:
# run_ui_tests user <test_name> <playright_options>
#   test_name: any .ts file located in ./tests
#   playright_options: --debug
set -e
USER_NAME=$1
AZHOP_CONFIG=config.yml
ANSIBLE_VARIABLES=playbooks/group_vars/all.yml

echo "Retrieve Username, password and FQDN"
key_vault=$(yq eval '.key_vault' $ANSIBLE_VARIABLES)
if [ -z "$USER_NAME" ]; then
    USER_NAME=$(yq eval '.users[0].name' $AZHOP_CONFIG)
else
    shift
fi

password=$(./bin/get_secret $USER_NAME)
export AZHOP_USER=$USER_NAME
export AZHOP_PASSWORD=$password

fqdn=$(yq eval '.ondemand_fqdn' $ANSIBLE_VARIABLES)
export AZHOP_FQDN="https://$fqdn"

echo "FQDN is $AZHOP_FQDN"
echo "User is $AZHOP_USER"
npx playwright test --config=tests/playwright.config.ts $@
