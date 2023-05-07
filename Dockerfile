FROM golang:1.20 AS build_base

RUN mkdir /compile
  
COPY supervisor/ /compile  

RUN cd /compile && CGO_ENABLED=0 go build -o /compile/supervisor .


FROM alpine:3.15

RUN apk add ca-certificates curl && mkdir /app && touch /app/.isdocker

RUN \
 mkdir -p \
	/app \
	/config \
	/defaults 

# add local files
COPY root/ /


# install packages
RUN \
 echo "**** installing os packages ****" && \
 apk add --no-cache \
	apache2-utils \
	bash \
	ca-certificates \
	coreutils \
	curl \
	evtest \
	libressl3.4-libssl \
	nano \
	nginx \
	openssl \
	php8 \
	php8-curl \
	php8-fileinfo \
	php8-fpm \
	php8-gettext \
	php8-json \
	php8-mbstring \
	php8-openssl \
	php8-pdo \
	php8-pdo_sqlite \
	php8-redis \
	php8-session \
	php8-simplexml \
	php8-sockets \
	php8-sqlite3 \
	php8-xml \
	php8-xmlwriter \
	php8-zlib \
	procps \
	redis \
	screen \
	shadow \
	sudo \
	tzdata && \
 echo 'fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;' >> \
	/etc/nginx/fastcgi_params && \
 rm -f /etc/nginx/conf.d/default.conf && \
 chown redis:redis /etc/redis.conf && \
 useradd -d /config -s /bin/false barcodebuddy && \
 chmod 755 /etc && \
 chown barcodebuddy:barcodebuddy -R /var/log/php8


# set version label
ARG BUILD_DATE
ARG VERSION
ARG BBUDDY_RELEASE
LABEL build_version="BarcodeBuddy ${VERSION} Build ${BUILD_DATE}"
LABEL maintainer="Marc Ole Bulling"



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
   sed -i 's/[[:blank:]]*const[[:blank:]]*IS_DOCKER[[:blank:]]*=[[:blank:]]*false;/const IS_DOCKER = true;/g' /app/bbuddy/config-dist.php && \
 echo "Set disable_coredump false" > /etc/sudo.conf && \
sed -i 's/SCRIPT_LOCATION=.*/SCRIPT_LOCATION="\/app\/bbuddy\/index.php"/g' /app/bbuddy/example/grabInput.sh && \
 sed -i 's/pm.max_children = 5/pm.max_children = 20/g' /etc/php8/php-fpm.d/www.conf && \
sed -i 's/WWW_USER=.*/WWW_USER="barcodebuddy"/g' /app/bbuddy/example/grabInput.sh && \
sed -i 's/IS_DOCKER=.*/IS_DOCKER=true/g' /app/bbuddy/example/grabInput.sh && \
sed -i 's/const DEFAULT_USE_REDIS =.*/const DEFAULT_USE_REDIS = "1";/g' /app/bbuddy/incl/db.inc.php && \
 rm -rf \
	/root/.cache \
	/tmp/*

#Bug in sudo requires disable_coredump
#Max children need to be a higher value, otherwise websockets / SSE might not work properly

COPY --from=build_base /compile/supervisor /app/supervisor

EXPOSE 80 443
VOLUME /config

CMD ["/app/supervisor"]

