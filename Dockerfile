# Version 0.0.1
FROM uwinart/base:latest

MAINTAINER Yurii Khmelevskii <y@uwinart.com>

# Install NGINX
RUN cd /usr/local/src && \
  wget http://nginx.org/keys/nginx_signing.key && \
  apt-key add nginx_signing.key && \
  rm -f nginx_signing.key && \
  echo "deb http://nginx.org/packages/debian/ wheezy nginx" >> /etc/apt/sources.list.d/nginx.list && \
  echo "deb-src http://nginx.org/packages/debian/ wheezy nginx" >> /etc/apt/sources.list.d/nginx.list && \
  apt-get -q update && \
  apt-get build-dep -y nginx && \
  apt-get source nginx && \
  git clone https://github.com/openresty/echo-nginx-module && \
  cd /usr/local/src/nginx-* && \
  mkdir debian/modules && \
  cd debian/modules && \
  ln -s /usr/local/src/echo-nginx-module && \
  apt-get install -yq libgeoip-dev geoip-database libgeoip1 && \
  cd /usr/local/src/nginx-* && \
  sed -i '/WITH_SPDY/a --add-module=$(CURDIR)/debian/modules/echo-nginx-module --with-http_geoip_module \\' debian/rules && \
  dpkg-buildpackage -uc -b -j2 && \
  dpkg -i ../nginx_*\~wheezy_amd64.deb && \
  aptitude hold nginx && \
  rm -f /usr/local/src/nginx_* && \
  rm -f /usr/local/src/nginx-debug* && \
  echo "daemon off;" >> /etc/nginx/nginx.conf

RUN mkdir -p /var/spool/nginx/tmp && \
  chown nginx:nginx /var/spool/nginx/tmp

EXPOSE 80

CMD ["/usr/sbin/nginx"]
