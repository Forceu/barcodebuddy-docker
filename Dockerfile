FROM lsiobase/nginx:3.11

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BBUDDY_RELEASE
LABEL build_version="BarcodeBuddy Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Marc Ole Bulling"



RUN \
 echo "**** Installing runtime packages ****" && \
 apk add --no-cache \
	curl \
	sudo \
	php7 \
	curl \
	php7-curl \
	php7-sqlite3
#https://github.com/Forceu/barcodebuddy/archive/${BBUDDY_RELEASE}.tar.gz
RUN \
 echo "**** Installing BarcodeBuddy ****" && \
 mkdir -p /app/bbuddy && \
 if [ -z ${BBUDDY_RELEASE+x} ]; then \
	BBUDDY_RELEASE=$(curl -sX GET "https://api.github.com/repos/Forceu/barcodebuddy/releases/latest" \
	| awk '/tag_name/{print $4}' FS='[""]'); \
 fi && \
 curl -o \
	/tmp/bbuddy.tar.gz -L \
	"https://bulling.mobi/barcodebuddy-preview.tar.gz" && \
 tar xf \
	/tmp/bbuddy.tar.gz -C \
	/app/bbuddy/ --strip-components=1 && \
   sed -i 's/[[:blank:]]*const[[:blank:]]*IS_DOCKER[[:blank:]]*=[[:blank:]]*false;/const IS_DOCKER = true;/g' /app/bbuddy/incl/config.php

#Bug in sudo requires this
RUN echo "Set disable_coredump false" > /etc/sudo.conf

RUN \
 echo "**** Cleanup ****" && \
 rm -rf \
	/root/.cache \
	/tmp/*

RUN groupadd -r websocket && useradd -r -g websocket websocket

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 6783
EXPOSE 6784
VOLUME /config
