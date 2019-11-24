**Forked from:**
https://github.com/getsentry/onpremise/tree/stable

Sentry Rancher stack deployment added with Let's Encrypt support.

# Sentry On-Premise with Rancher 1.6 support

[![Docker Pulls](https://img.shields.io/docker/pulls/mgbi/sentry.svg?maxAge=8600)][hub]
[![License](https://img.shields.io/github/license/mgbi/onpremise.svg?maxAge=8600)]()

[hub]: https://hub.docker.com/r/mgbi/sentry/

Official bootstrap for running your own [Sentry](https://sentry.io/) with [Docker](https://www.docker.com/)
on [Rancher v1.6](https://rancher.com/docs/rancher/v1.6/en/).

## Requirements

 * Docker 17.05.0+
 * Compose 1.17.0+

## Minimum Hardware Requirements:

 * You need at least 3GB RAM

## Setup

To get started with all the defaults, simply clone the repo and run `./install.sh` in your local check-out.

There may need to be modifications to the included `docker-compose.yml` file to accommodate your needs or your environment (such as adding GitHub credentials). If you want to perform these, do them before you run the install script.

The recommended way to customize your configuration is using the files below, in that order:

 * `config.yml`
 * `sentry.conf.py`
 * `.env` w/ environment variables

If you have any issues or questions, our [Community Forum](https://forum.sentry.io/c/on-premise) is at your service!

## Securing Sentry with SSL/TLS

If you'd like to protect your Sentry install with SSL/TLS, there are
fantastic SSL/TLS proxies like [HAProxy](http://www.haproxy.org/)
and [Nginx](http://nginx.org/). You'll likely to add this service to your `docker-compose.yml` file.

## Updating Sentry

Updating Sentry using Compose is relatively simple. Just use the following steps to update. Make sure that you have the latest version set in your Dockerfile. Or use the latest version of this repository.

Use the following steps after updating this repository or your Dockerfile:
```sh
docker-compose build --pull # Build the services again after updating, and make sure we're up to date on patch version
docker-compose run --rm web upgrade # Run new migrations
docker-compose up -d # Recreate the services
```

## Extra

### Setup Sentry Rancher stack

Do not run `./install.sh`.

0. Build and push an image to your repository. You can also use our public image:
`mgbi/sentry:9.1.2`.
```
./s/build_and_push_docker_images.sh
```
1. Set environment variables. List of supported variables is in `sentry.conf.py`.
Rancher secrets are marked with `*Rancher secret*` annotation.
```
cp .env.example .env
vim .env
```
2. Set Rancher API credentials.
```
cp load_rancher_env_template.sh load_rancher_env.sh
vim load_rancher_env.sh
```
3. Generate secret key.
```
./s/generate-secret-key.sh
```
4. Launch Rancher Secrets from the Rancher Catalog.
5. Deploy the first time without https and with sentry sleeping.
```
./s/prod-compose.sh
```
6. Check in Rancher UI whether letsencrypt got your certificate.
7. Upgrade web container.
```
source load_rancher_env.sh
rancher exec -it sentry/web /entrypoint.sh upgrade
```
8. Deploy second time with https and sentry running.
```
./s/prod-compose.sh
```


## Resources

 * [Documentation](https://docs.sentry.io/server/installation/docker/)
 * [Bug Tracker](https://github.com/getsentry/onpremise/issues)
 * [Forums](https://forum.sentry.io/c/on-premise)
 * [IRC](irc://chat.freenode.net/sentry) (chat.freenode.net, #sentry)


[build-status-image]: https://api.travis-ci.com/getsentry/onpremise.svg?branch=master
[build-status-url]: https://travis-ci.com/getsentry/onpremise
