#!/bin/bash -e
# adapted from install.sh

ENV_FILE='.env'

echo "Generating secret key..."
# This is to escape the secret key to be used in sed below
SECRET_KEY=$(docker run --rm sentry:latest config generate-secret-key 2> /dev/null | tail -n1 | sed -e 's/[\/&]/\\&/g')
sed -i -e 's/^SENTRY_SECRET_KEY=.*$/SENTRY_SECRET_KEY="'"$SECRET_KEY"'"/' $ENV_FILE
echo "Secret key written to $ENV_FILE"
