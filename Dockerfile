#
# ---- Base ----

FROM alpine:latest as base

ENV VARNISH_VERSION=7.0.2-r0 \
    VCL_DIR='/etc/varnish' \
    VCL_FILE='default.vcl' \
    VARNISH_CACHE_SIZE=64m \
    VARNISH_PORT=80
  
RUN apk add -q \
    npm \
    curl \
    git \
    gzip \
    tar \
    sudo

RUN apk --update add \
  varnish=$VARNISH_VERSION

COPY package.json /.

#
# ---- Build ----

FROM base as build
WORKDIR /tmp

RUN apk --update add \
  varnish-dev=$VARNISH_VERSION

RUN apk add -q \
    autoconf \
    automake \
    build-base \
    ca-certificates \
    cpio \
    gzip \
    libedit-dev \
    libtool \
    libunwind-dev \
    linux-headers \
    pcre-dev \
    py-docutils \
    py3-sphinx \
    tar \
    sudo

RUN git clone --depth=1 https://github.com/varnish/varnish-modules.git \
  && cd varnish-modules \
  && ./bootstrap \
  && ./configure --prefix=/usr \
  && make -j4 \
  && make check \
  && make install

RUN curl -L https://github.com/DarthSim/hivemind/releases/download/v1.1.0/hivemind-v1.1.0-linux-amd64.gz -o hivemind.gz \
  && gunzip hivemind.gz \
  && mv hivemind /usr/local/bin

RUN rm -rf /tmp

#
# ---- Dependencies ----

FROM base AS dependencies

RUN npm set progress=false && npm config set depth 0
RUN npm install --only=production 
RUN cp -R node_modules /prod_node_modules
RUN npm install

#
# ---- Release ----
FROM base AS release
WORKDIR /app
COPY --from=dependencies /prod_node_modules ./node_modules
COPY --from=build /usr/local/bin/hivemind /usr/local/bin/hivemind
COPY --from=build /usr/lib/varnish/vmods/ /usr/lib/varnish/vmods/

COPY . .
COPY default.vcl /etc/varnish/default.vcl
COPY Procfile Procfile

RUN chmod +x /usr/local/bin/hivemind
RUN chmod +x /app/scripts/*.sh

EXPOSE 3000 8080
ENV PORT=3000

RUN ["chmod", "+w", "/dev/stdout"]

CMD ["/usr/local/bin/hivemind"]