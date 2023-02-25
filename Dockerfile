FROM lsiobase/nginx:3.15-php8

#Build example: docker build --no-cache --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="v1.4.0.0" -t forceu/barcodebuddy-docker .

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BBUDDY_RELEASE
LABEL build_version="BarcodeBuddy ${VERSION} Build ${BUILD_DATE}"
LABEL maintainer="Marc Ole Bulling"



RUN \
 echo "**** Installing runtime packages ****" && \
 apk add --no-cache \
        curl \
        evtest \
        php8 \
        php8-curl \
        php8-gettext \
        php8-mbstring \
        php8-openssl \
        php8-pdo \
        php8-pdo_sqlite \
        php8-sqlite3 \
        php8-sockets \
        php8-redis \
        redis \
        screen \
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
   sed -i 's/[[:blank:]]*const[[:blank:]]*IS_DOCKER[[:blank:]]*=[[:blank:]]*false;/const IS_DOCKER = true;/g' /app/bbuddy/config-dist.php && \
 echo "Set disable_coredump false" > /etc/sudo.conf && \
sed -i 's/SCRIPT_LOCATION=.*/SCRIPT_LOCATION="\/app\/bbuddy\/index.php"/g' /app/bbuddy/example/grabInput.sh && \
 sed -i 's/pm.max_children = 5/pm.max_children = 20/g' /etc/php8/php-fpm.d/www.conf && \
sed -i 's/WWW_USER=.*/WWW_USER="abc"/g' /app/bbuddy/example/grabInput.sh && \
sed -i 's/IS_DOCKER=.*/IS_DOCKER=true/g' /app/bbuddy/docker/parseEnv.sh && \
sed -i 's/IS_DOCKER=.*/IS_DOCKER=true/g' /app/bbuddy/example/grabInput.sh && \
sed -i 's/const DEFAULT_USE_REDIS =.*/const DEFAULT_USE_REDIS = "1";/g' /app/bbuddy/incl/db.inc.php && \
(crontab -l 2>/dev/null; echo "* * * * * sudo -u abc /usr/bin/php /app/bbuddy/cron.php >/dev/null 2>&1") | crontab - && \
echo "**** Cleanup ****" && \
 rm -rf \
	/root/.cache \
	/tmp/*

#Bug in sudo requires disable_coredump
#Max children need to be a higher value, otherwise websockets / SSE might not work properly

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config
