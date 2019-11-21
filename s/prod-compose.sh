#!/bin/bash -e
# Deployment:
# ./s/prod-compose.sh

ENV_FILE='.env'
STACK_NAME=${RANCHER_STACK_NAME:-sentry}

rancher_cli () {
	rancher --file docker-compose.yml --file docker-compose.rancher.yml \
		--rancher-file rancher-compose.yml "$@"
}

sleep_sentry () {
	sed -i 's/command: .*/command: sleep infinity/' docker-compose.yml
}

restore_sentry () {
  git co docker-compose.yml
}

disable_https () {
	sed -i -e "/certs:/,+1d" -e "/default_cert:/d" -e "/protocol: https/,+3d" rancher-compose.yml
}

enable_https () {
	# revert any changes
	git checkout rancher-compose.yml
}

cleanup () {
	rm -rf secrets
	enable_https
	restore_sentry
}

trap cleanup EXIT

# load secrets
source $ENV_FILE

test $SENTRY_SECRET_KEY
test $SENTRY_EMAIL_PASSWORD
test $SENTRY_DB_PASSWORD
test $GITHUB_API_SECRET

# the contents of the specified files will be used to create the secrets
# before creating the stack and starting the services
mkdir -p secrets
echo $SENTRY_SECRET_KEY > secrets/sentry-secret-key.txt
echo $SENTRY_EMAIL_PASSWORD > secrets/sentry-email-password.txt
echo $SENTRY_DB_PASSWORD > secrets/sentry-db-password.txt
echo $GITHUB_API_SECRET > secrets/github-api-secret.txt

source load_rancher_env.sh

# disable https protocol if the load balancer is not running yet
# (acme challenge could not be passed yet and the certificate is not ready)
rancher ps $RANCHER_STACK_NAME/lb || (disable_https && DISABLED_HTTPS=1)

# sleep sentry for web upgrade if the web is not running yet
rancher ps $RANCHER_STACK_NAME/web || (sleep_sentry && SLEPT_SENTRY=1)

rancher_cli up -d --stack $RANCHER_STACK_NAME --env-file $ENV_FILE --pull --upgrade --confirm-upgrade \
	--description "Sentry error tracking tool"

if [ "$DISABLED_HTTPS" = 1 ]; then
	echo "Waiting for the SSL certificate. Please deploy lb once again when it is ready"
fi

if [ "$SLEPT_SENTRY" = 1 ]; then
	echo "Waiting for the web upgrade."
fi
