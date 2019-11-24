#!/bin/bash -e
# Load secrets passed as the script parameters
source /usr/local/src/file-env.sh

SECRETS_DIR=/run/secrets

vars_names=( "$@" )

if [ -z "$1" ]; then
	if [ -d $SECRETS_DIR ]; then
		secrets_count=$(ls -A $SECRETS_DIR | wc -l)
		if [ $secrets_count -gt 0 ]; then
			echo "Found $secrets_count available secrets."
			vars_names=( `ls -A $SECRETS_DIR | tr '[a-z]-' '[A-Z]_'` )
		else
			echo "No available secrets."
		fi
	else
		echo "Secrets directory does not exist."
	fi
fi

for var_name in "${vars_names[@]}"
do
	if [ -n "$var_name" ]; then
		echo "Loading $var_name secret..."
		file_env "$var_name"
	fi
done
