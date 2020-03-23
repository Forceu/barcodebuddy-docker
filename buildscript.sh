#!/bin/bash

HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="Barcode Buddy"
TITLE="Docker Build Script"
MENU="Choose one of the following options:"

OPTIONS=(1 "Build and release dev image"
         2 "Build and release all images")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            echo "Building dev image"
	    docker build --no-cache --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` -t f0rc3/barcodebuddy-docker:latest-dev -f Dockerfile.dev .
            echo "Pushing dev image"
	    docker push f0rc3/barcodebuddy-docker:latest-dev
            ;;
        2)
            echo "Building all images"
	    echo "Please enter release version:"
	    read version
	    cp /usr/bin/qemu-arm-static .
	    cp /usr/bin/qemu-aarch64-static .
	    docker build --no-cache --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` -t f0rc3/barcodebuddy-docker:latest-dev -f Dockerfile.dev .
	    docker build --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="${version}" -t f0rc3/barcodebuddy-docker:latest -f Dockerfile .
	    docker build --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="${version}" -t f0rc3/barcodebuddy-docker:arm64v8-latest -f Dockerfile.aarch64 .
	    docker build --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="${version}" -t f0rc3/barcodebuddy-docker:arm32v7-latest -f Dockerfile.armhf .
	    docker push f0rc3/barcodebuddy-docker:latest-dev
	    docker push f0rc3/barcodebuddy-docker:latest
	    docker push f0rc3/barcodebuddy-docker:arm64v8-latest
	    docker push f0rc3/barcodebuddy-docker:arm32v7-latest
	    rm qemu-arm-static
	    rm qemu-aarch64-static
            ;;
esac
