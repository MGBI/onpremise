#!/bin/bash
# Adapted from:
# https://github.com/getsentry/docker-sentry/blob/master/9.1/docker-entrypoint.sh

set -e

if [ "$1" != "sleep" ]; then
	# load available secret environment variables
	source load-secrets ""
fi

# first check if we're passing flags, if so
# prepend with sentry
if [ "${1:0:1}" = '-' ]; then
	set -- sentry "$@"
fi

case "$1" in
	celery|cleanup|config|createuser|devserver|django|exec|export|help|import|init|plugins|queues|repair|run|shell|start|tsdb|upgrade)
		set -- sentry "$@"
	;;
esac

if [ "$1" = 'sentry' ]; then
	set -- tini -- "$@"
	if [ "$(id -u)" = '0' ]; then
		mkdir -p "$SENTRY_FILESTORE_DIR"
		find "$SENTRY_FILESTORE_DIR" ! -user sentry -exec chown sentry {} \;
		set -- gosu sentry "$@"
	fi
fi

exec "$@"
