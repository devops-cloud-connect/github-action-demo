#!/bin/sh

# Decrypt the file
mkdir $HOME/secrets
# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$DEPLOY_KEY" \
--output ${GITHUB_WORKSPACE}/contracts/my_secret.json ${GITHUB_WORKSPACE}/contracts/my_secret.json.gpg