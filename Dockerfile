FROM lsiobase/nginx:3.11

#Build example: docker build --no-cache --pull -t forceu/barcodebuddy-docker .

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
	php7 \
	php7-curl \
	php7-sqlite3 \
	php7-sockets \
	sudo
RUN \
 echo "**** Installing BarcodeBuddy ****" && \
 mkdir -p /app/bbuddy && \
 if [ -z ${BBUDDY_RELEASE+x} ]; then \
	BBUDDY_RELEASE=$(curl -sX GET "https://api.github.com/repos/Forceu/barcodebuddy/releases/latest" \
	| awk '/tag_name/{print $4; exit}' FS='[""]'); \
 fi && \
 curl -o \
	/tmp/bbuddy.tar.gz -L \
	"https://github.com/Forceu/barcodebuddy/archive/${BBUDDY_RELEASE}.tar.gz" && \
 tar xf \
	/tmp/bbuddy.tar.gz -C \
	/app/bbuddy/ --strip-components=1 && \
   sed -i 's/[[:blank:]]*const[[:blank:]]*IS_DOCKER[[:blank:]]*=[[:blank:]]*false;/const IS_DOCKER = true;/g' /app/bbuddy/incl/config.php && \
echo "Set disable_coredump false" > /etc/sudo.conf && groupadd -r websocket && useradd -r -g websocket websocket && \
sed -i 's/pm.max_children = 5/pm.max_children = 200/g' /etc/php7/php-fpm.d/www.conf
#Bug in sudo requires disable_coredump
#Max children need to be a higher value, otherwise websockets / SSE might not work properly

RUN \
 echo "**** Cleanup ****" && \
 rm -rf \
	/root/.cache \
	/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config
