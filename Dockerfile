FROM golang:1.27 AS build_base
LABEL stage=builder

RUN mkdir /compile
  
COPY supervisor/ /compile  

RUN cd /compile && CGO_ENABLED=0 go build -o /compile/supervisor .


FROM alpine:3.24

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
	nano \
	nginx \
	openssl \
	php85 \
	php85-curl \
	php85-fileinfo \
	php85-fpm \
	php85-gettext \
	php85-json \
	php85-mbstring \
	php85-openssl \
	php85-pdo \
	php85-pdo_sqlite \
	php85-redis \
	php85-session \
	php85-simplexml \
	php85-sockets \
	php85-sqlite3 \
	php85-xml \
	php85-xmlwriter \
	php85-zlib \
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
 chown barcodebuddy:barcodebuddy -R /var/log/php85 && \
 chown barcodebuddy:barcodebuddy -R /app && \
 ln -s /usr/bin/php85 /usr/bin/php8 && \
 ln -s /config /data


# set version label
ARG BUILD_DATE
ARG VERSION
# Tag, branch or commit hash of Forceu/barcodebuddy to build.
# If empty, the latest release tag is used.
ARG BBUDDY_REF=""
LABEL build_version="BarcodeBuddy ${VERSION} Build ${BUILD_DATE}"
LABEL maintainer="Marc Ole Bulling"



RUN \
 echo "**** Installing BarcodeBuddy ****" && \
 apk add --no-cache --virtual .build-deps git && \
 mkdir -p /app/bbuddy && \
 BBUDDY_REPO="https://github.com/Forceu/barcodebuddy.git" && \
 if [ -z "${BBUDDY_REF}" ]; then \
	BBUDDY_REF=$(git ls-remote --tags --refs --sort=-v:refname "${BBUDDY_REPO}" \
	| head -n 1 | sed 's|.*refs/tags/||'); \
 fi && \
 if [ -z "${BBUDDY_REF}" ]; then \
	echo "Could not determine latest release" >&2; exit 1; \
 fi && \
 echo "Using BarcodeBuddy ref: ${BBUDDY_REF}" && \
 cd /app/bbuddy && \
 git init -q . && \
 git remote add origin "${BBUDDY_REPO}" && \
 git fetch -q --depth 1 origin "${BBUDDY_REF}" && \
 git checkout -q FETCH_HEAD && \
 rm -rf /app/bbuddy/.git && \
 apk del .build-deps && \
   sed -i 's/[[:blank:]]*const[[:blank:]]*IS_DOCKER[[:blank:]]*=[[:blank:]]*false;/const IS_DOCKER = true;/g' /app/bbuddy/config-dist.php && \
 echo "Set disable_coredump false" > /etc/sudo.conf && \
sed -i 's/SCRIPT_LOCATION=.*/SCRIPT_LOCATION="\/app\/bbuddy\/index.php"/g' /app/bbuddy/example/grabInput.sh && \
 sed -i 's/pm.max_children = 5/pm.max_children = 20/g' /etc/php85/php-fpm.d/www.conf && \
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

