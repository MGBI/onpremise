ARG SENTRY_IMAGE
FROM ${SENTRY_IMAGE}-onbuild

# Script for loading sensitive data (secrets)
COPY docker/file-env.sh /usr/local/src/
COPY docker/load-secrets.sh /usr/local/bin/load-secrets
# Loading available secret environment variables on shell start
RUN echo 'source load-secrets' >> /etc/bash.bashrc
