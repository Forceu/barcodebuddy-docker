# BarcodeBuddy on Docker

BarcodeBuddy- now containerized! This is the docker repo of [BarcodeBuddy](https://github.com/Forceu/barcodebuddy).

[![Documentation Status](https://readthedocs.org/projects/barcodebuddy-documentation/badge/?version=latest)](https://barcodebuddy-documentation.readthedocs.io/en/latest/?badge=latest)
[![Docker Pulls](https://img.shields.io/docker/pulls/f0rc3/barcodebuddy-docker.svg)](https://hub.docker.com/r/f0rc3/barcodebuddy-docker/)

### Install Docker

Follow [these instructions](https://docs.docker.com/engine/installation/) to get Docker running on your server.

### Available on Docker Hub (prebuilt) or built from source

### To pull the latest images to your machine:

```
docker pull f0rc3/barcodebuddy:latest
docker run -d -v bbconfig:/config -p 8080:80 -p 4433:443 f0rc3/barcodebuddy:latest
```

Replace the ports 8080 and 4433 with a port of your choice, which will be exposed on your local machine.

## Documentation

Please have a look at the [documentation](https://barcodebuddy-documentation.readthedocs.io/en/latest/), for more information on how to install and use the docker image.

#### Architectures

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| amd64 | latest |
| arm64 | latest |
| armhf | latest |
| x86 | latest |

#### Developer image

If you would like to use the unstable channel, which includes all commits and might be more up to date than the release, use the following command:

```
docker pull f0rc3/barcodebuddy:latest-dev
```



The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| amd64 | latest-dev |
| arm64 | latest-dev  |
| armhf | latest-dev  |
| x86 | latest-dev  |

### To build from scratch

#### Latest release
```
docker build --no-cache --pull -t forceu/barcodebuddy .
```
#### Latest commit (unstable)
```
docker build --no-cache --pull -t forceu/barcodebuddy-dev -f Dockerfile.dev .
```

## Additional Information

### Websockets

In the current version, the websockets are only used for internal communication. Everything will work out of the box.

### Exposed Ports

 - 80:    HTTP
 - 443:   HTTPS

### Misc

The docker images build are based on [Alpine](https://hub.docker.com/_/alpine/), with an extremely low footprint (about 70MB in total).


## Contributors
<a href="https://github.com/forceu/barcodebuddy-docker/graphs/contributors">
  <img src="https://contributors-img.web.app/image?repo=forceu/barcodebuddy-docker" />
</a>

## License
The MIT License (MIT)

Based on: https://github.com/linuxserver/docker-grocy

## Donations

As with all Free software, the power is less in the finances and more in the collective efforts. I really appreciate every pull request and bug report offered up by BarcodeBuddy's users, so please keep that stuff coming. If however, you're not one for coding/design/documentation, and would like to contribute financially, you can do so with the link below. Every help is very much appreciated!

[![paypal](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=donate@bulling.mobi&lc=US&item_name=BarcodeBuddy&no_note=0&cn=&currency_code=EUR&bn=PP-DonationsBF:btn_donateCC_LG.gif:NonHosted) [![LiberaPay](https://img.shields.io/badge/Donate-LiberaPay-green.svg)](https://liberapay.com/MBulling/donate)
