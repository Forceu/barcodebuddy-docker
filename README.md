# BarcodeBuddy on Docker

BarcodeBuddy- now containerized! This is the docker repo of [BarcodeBuddy](https://github.com/Forceu/barcodebuddy).

[![Docker Pulls](https://img.shields.io/docker/pulls/f0rc3/barcodebuddy-docker.svg)](https://hub.docker.com/r/f0rc3/barcodebuddy-docker/)
[![Docker Stars](https://img.shields.io/docker/stars/f0rc3/barcodebuddy-docker.svg)](https://hub.docker.com/r/f0rc3/barcodebuddy-docker/)

## Install Docker

Follow [these instructions](https://docs.docker.com/engine/installation/) to get Docker running on your server.

## Available on Docker Hub (prebuilt) or built from source

### To pull the latest images to your machine:

```
docker pull f0rc3/barcodebuddy-docker:v1
docker run -d -p 80:80 -p 443:443 -p 47631:47631 f0rc3/barcodebuddy-docker:v1
```

BarcodeBuddy should be accessible via `http(s)://DOCKER_HOST_IP/`. The https option will work. However, since the certificate is self-signed, most browsers will complain.


### To build from scratch

```
docker build --no-cache --pull -t forceu/barcodebuddy-docker .
```

## Additional Information

### Websockets

Although the Websocket server will be started automatically, you still need to set it up - if you are accessing BarcodeBuddy with HTTPS, the websocket connection needs to be secured as well (wss:// instead of ws://), otherwise most browsers reject the connection.

We recommend nginx for this, use the example file and adjust the config. In the BBuddy webinterface, go to Settings and tick "Use SSL proxy" (even if you are not using one). If you are serving the site through a HTTP connection, enter `ws://IP_OF_SERVER:47631/screen` (make sure to forward the port if needed). If you are using nginx as a ssl reverse proxy, enter `wss://NGINX_URL/screen` instead.

### Exposed hosts

 - 80:    HTTP
 - 443:   HTTPS
 - 47631: Websockets

### Misc

The docker images build are based on [Alpine](https://hub.docker.com/_/alpine/), with an extremely low footprint (about 70MB in total).

## License
The MIT License (MIT)

Based on: https://github.com/linuxserver/docker-grocy
