#
# ---- Base ----

FROM alpine:latest as base

ENV VARNISH_VERSION=7.0.2-r0 \
    VCL_DIR='/etc/varnish' \
    VCL_FILE='default.vcl' \
    VARNISH_CACHE_SIZE=64m \
    VARNISH_PORT=80

RUN mkdir /apps/fly-varnish -p
RUN mkdir /data;

RUN apk add -q npm yarn curl git gzip tar

RUN apk --update add varnish=$VARNISH_VERSION

RUN export PKG_CONFIG_PATH=/dlib-install/usr/local/lib64/pkgconfig/

#
# ---- Build ----

FROM base as build
WORKDIR /tmp

RUN apk --update add varnish-dev=$VARNISH_VERSION

RUN apk add -q \
    make \
    autoconf \
    automake \
    build-base \
    ca-certificates \
    cpio \
    gzip \
    graphviz \
    libedit-dev \
    libtool \
    libunwind-dev \
    linux-headers \
    pcre-dev \
    py-docutils \
    py3-sphinx \
    tar

RUN git clone --depth=1 https://github.com/varnish/varnish-modules.git \
  && cd varnish-modules \
  && ./bootstrap \
  && ./configure --prefix=/usr \
  && make -j4 \
  && make install

RUN export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

RUN git clone --recursive https://github.com/maxmind/libmaxminddb && \
  cd libmaxminddb && \
  ./bootstrap && \
  ./configure && \
  make && \
  make check && \
  make install

RUN git clone --recursive https://github.com/fgsch/libvmod-geoip2 && \
    cd libvmod-geoip2 && \
    git checkout main && \
    ./autogen.sh && \
    ./configure && \
    make check && \
    make install


RUN curl -L https://github.com/DarthSim/hivemind/releases/download/v1.1.0/hivemind-v1.1.0-linux-amd64.gz -o hivemind.gz \
  && gunzip hivemind.gz \
  && mv hivemind /usr/local/bin

RUN rm -rf /tmp

# #
# # ---- Dependencies ----

FROM base AS dependencies

WORKDIR /apps/fly-varnish

COPY package.json .
RUN npm set progress=false && npm config set depth 0
RUN npm install --only=production 
RUN cp -R node_modules ./prod_node_modules
RUN npm install
RUN rm package.json
# #
# # ---- DATA ----

# ARG MAXMIND_LICENSE_KEY

# RUN if test -z $MAXMIND_LICENSE_KEY && test ! -f /data/GeoLite2-City.mmdb ; then\
#   echo "********** MAXMIND_LICENSE_KEY IS NOT FOUND"; \
# else\
#   echo "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${MAXMIND_LICENSE_KEY}&suffix=tar.gz" ;\
#   curl -L "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${MAXMIND_LICENSE_KEY}&suffix=tar.gz" | tar xz ;\
#   mv */*.mmdb  /data;\
#   ls /data;\
# fi

#
# ---- Release ----
FROM base AS release
WORKDIR /apps/fly-varnish
COPY --from=dependencies /apps/fly-varnish/prod_node_modules /apps/fly-varnish/node_modules
COPY --from=build /usr/local/bin/hivemind /usr/local/bin/hivemind
COPY --from=build /usr/lib/varnish/vmods/ /usr/lib/varnish/vmods/
COPY --from=build /usr/local/lib/libmaxminddb.*  /usr/local/lib/

# COPY --from=dependencies /data /data

COPY /apps/fly-varnish/* /apps/fly-varnish/
COPY /apps/fly-varnish/default.vcl /etc/varnish/default.vcl
COPY /apps/fly-varnish/Procfile Procfile

RUN ls /apps/fly-varnish

RUN chmod +x /usr/local/bin/hivemind
RUN chmod +x /apps/fly-varnish/*.sh

WORKDIR /apps/fly-varnish

EXPOSE 3000 8080
ENV PORT=3000

RUN ["chmod", "+w", "/dev/stdout"]

CMD ["/usr/local/bin/hivemind"]