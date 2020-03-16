# BarcodeBuddy on Docker

BarcodeBuddy- now containerized! This is the docker repo of [BarcodeBuddy](https://github.com/Forceu/barcodebuddy).

[![Docker Pulls](https://img.shields.io/docker/pulls/f0rc3/barcodebuddy-docker.svg)](https://hub.docker.com/r/f0rc3/barcodebuddy-docker/)
[![Docker Stars](https://img.shields.io/docker/stars/f0rc3/barcodebuddy-docker.svg)](https://hub.docker.com/r/f0rc3/barcodebuddy-docker/)

## Install Docker

Follow [these instructions](https://docs.docker.com/engine/installation/) to get Docker running on your server.

## Available on Docker Hub (prebuilt) or built from source

### To pull the latest images to your machine:

```
docker pull f0rc3/barcodebuddy-docker
```

BarcodeBuddy should be accessible via `http(s)://localhost/`. The https option will work. However, since the certificate is self-signed, most browsers will complain.


### To build from scratch

```
docker build --no-cache --pull -t forceu/barcodebuddy-docker .
```

## Additional Information

The docker images build are based on [Alpine](https://hub.docker.com/_/alpine/), with an extremelly low footprint (about 70MB in total).

## License
The MIT License (MIT)

Based on: https://github.com/linuxserver/docker-grocy
