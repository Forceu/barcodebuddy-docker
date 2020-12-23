#!/bin/bash
git pull
#sed -i 's/#COPY qemu-/COPY qemu-/g' Dockerfile*
HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="Barcode Buddy"
TITLE="Docker Build Script"
MENU="Choose one of the following options:"

OPTIONS=(1 "Build and release dev images"
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
            echo "Building dev images"
#	    cp /usr/bin/qemu-arm-static .
#	    cp /usr/bin/qemu-aarch64-static .
	    docker build --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="${version}" -t f0rc3/barcodebuddy-docker:latest-testing -f Dockerfile.testing .
	    docker build --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="${version}" -t f0rc3/barcodebuddy-docker:latest-dev -f Dockerfile.dev .
	    docker build --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="${version}" -t f0rc3/barcodebuddy-docker:arm64v8-latest-dev -f Dockerfile.dev.aarch64 .
	    docker build --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="${version}" -t f0rc3/barcodebuddy-docker:arm32v7-latest-dev -f Dockerfile.dev.armhf .
	    docker build --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="${version}" -t f0rc3/barcodebuddy-docker:i386-latest-dev -f Dockerfile.dev.i386 .
            echo "Pushing dev images"
	    docker push f0rc3/barcodebuddy-docker:latest-dev
	    docker push f0rc3/barcodebuddy-docker:latest-testing
	    docker push f0rc3/barcodebuddy-docker:arm64v8-latest-dev
	    docker push f0rc3/barcodebuddy-docker:arm32v7-latest-dev
	    docker push f0rc3/barcodebuddy-docker:i386-latest-dev
#	    rm qemu-arm-static
#	    rm qemu-aarch64-static
            ;;
        2)
            echo "Building all images"
	    echo "Please enter release version:"
	    read version
#	    cp /usr/bin/qemu-arm-static .
#	    cp /usr/bin/qemu-aarch64-static .
	    docker build --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="${version}" -t f0rc3/barcodebuddy-docker:latest-dev -f Dockerfile.dev .
	    docker build --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="${version}" -t f0rc3/barcodebuddy-docker:arm64v8-latest-dev -f Dockerfile.dev.aarch64 .
	    docker build --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="${version}" -t f0rc3/barcodebuddy-docker:arm32v7-latest-dev -f Dockerfile.dev.armhf .
	    docker build --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="${version}" -t f0rc3/barcodebuddy-docker:i386-latest-dev -f Dockerfile.dev.i386 .
	    docker build --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="${version}" -t f0rc3/barcodebuddy-docker:latest -f Dockerfile .
	    docker build --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="${version}" -t f0rc3/barcodebuddy-docker:arm64v8-latest -f Dockerfile.aarch64 .
	    docker build --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="${version}" -t f0rc3/barcodebuddy-docker:arm32v7-latest -f Dockerfile.armhf .
	    docker build --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="${version}" -t f0rc3/barcodebuddy-docker:i386-latest -f Dockerfile.i386 .
            echo "Pushing all images"
	    docker push f0rc3/barcodebuddy-docker:latest
	    docker push f0rc3/barcodebuddy-docker:i386-latest
	    docker push f0rc3/barcodebuddy-docker:arm64v8-latest
	    docker push f0rc3/barcodebuddy-docker:arm32v7-latest
	    docker push f0rc3/barcodebuddy-docker:latest-dev
	    docker push f0rc3/barcodebuddy-docker:i386-latest-dev
	    docker push f0rc3/barcodebuddy-docker:arm64v8-latest-dev
	    docker push f0rc3/barcodebuddy-docker:arm32v7-latest-dev

	    docker tag f0rc3/barcodebuddy-docker:latest f0rc3/barcodebuddy-docker:${version} 
	    docker tag f0rc3/barcodebuddy-docker:i386-latest f0rc3/barcodebuddy-docker:i386-${version} 
	    docker tag f0rc3/barcodebuddy-docker:arm64v8-latest f0rc3/barcodebuddy-docker:arm64v8-${version} 
	    docker tag f0rc3/barcodebuddy-docker:arm32v7-latest f0rc3/barcodebuddy-docker:arm32v7-${version} 

	    docker push f0rc3/barcodebuddy-docker:${version} 
	    docker push f0rc3/barcodebuddy-docker:i386-${version} 
	    docker push f0rc3/barcodebuddy-docker:arm64v8-${version} 
	    docker push f0rc3/barcodebuddy-docker:arm32v7-${version} 
#	    rm qemu-arm-static
#	    rm qemu-aarch64-static
            ;;
esac
