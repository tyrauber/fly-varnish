FROM node:lts-alpine3.15 as base
FROM base as build

ARG \
  VARNISH_VERSION=7.0.2-r0 \
  BUILD_TOOLS=" \
    varnish-dev \
    automake \
    autoconf \
    libtool \
    python3 \
    py-docutils \
    make \
    git \
    curl \
  "

RUN apk --update add \
  varnish=$VARNISH_VERSION \
  $BUILD_TOOLS

RUN cd /tmp \
  && git clone --depth=1 -b 0.19.0 https://github.com/varnish/varnish-modules.git \
  && cd varnish-modules \
  && ./bootstrap \
  && ./configure \
  && make -j $(nproc) \
  && make install

  # libmaxminddb
RUN git clone --recursive -b 1.6.0 https://github.com/maxmind/libmaxminddb \
  && cd libmaxminddb \
  && ./bootstrap \
  && ./configure \
  && make \
  && make install

RUN export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

  # libvmod-geoip2
RUN git clone --depth=1 -b 'v1.2.2' https://github.com/fgsch/libvmod-geoip2 \
  &&  cd libvmod-geoip2 \
  &&  ./autogen.sh \
  &&  ./configure \
  &&  make install

  # hivemind
RUN curl -L https://github.com/DarthSim/hivemind/releases/download/v1.1.0/hivemind-v1.1.0-linux-amd64.gz -o hivemind.gz \
  && gunzip hivemind.gz \
  && mv hivemind /usr/local/bin

RUN rm -rf tmp

FROM base AS dependencies

WORKDIR /apps/fly-varnish

COPY ./package.json .
RUN npm set progress=false \
  && npm config set depth 0 \
  && npm install --only=production \
  && cp -R node_modules ./prod_node_modules \
  && npm install \
  && rm package.json

FROM base as release

RUN apk add varnish

WORKDIR /apps/fly-varnish/
COPY *.sh *.js .
ADD Procfile Procfile
ADD default.vcl /etc/varnish/default.vcl

COPY --from=dependencies /apps/fly-varnish/prod_node_modules /apps/fly-varnish/node_modules
COPY --from=build /usr/lib/varnish/vmods/* /usr/lib/varnish/vmods/
COPY --from=build /usr/local/bin/hivemind /usr/local/bin/hivemind
COPY --from=build /usr/local/lib/libmaxminddb.*  /usr/local/lib/

RUN chmod +x /usr/local/bin/hivemind
RUN chmod +x /apps/fly-varnish/*.sh

EXPOSE 3000 8080
ENV PORT=3000

RUN ["chmod", "+w", "/dev/stdout"]

CMD ["/usr/local/bin/hivemind"]