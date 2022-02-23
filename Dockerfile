
# ---- Base Node ----

FROM varnish:fresh-alpine as base

ARG VARNISH_SIZE 100M

RUN apk add --update nodejs
RUN apk add -q \
    autoconf \
    automake \
    build-base \
    curl \
    ca-certificates \
    cpio \
    git \
    gzip \
    libedit-dev \
    libtool \
    libunwind-dev \
    linux-headers \
    npm \
    make \
    pcre2-dev \
    py-docutils \
    py3-sphinx \
    tar \
    sudo

COPY package.json .

# #
# # ---- Build ----

FROM base AS build

WORKDIR /opt

RUN curl -L https://github.com/DarthSim/hivemind/releases/download/v1.1.0/hivemind-v1.1.0-linux-amd64.gz -o hivemind.gz \
  && gunzip hivemind.gz \
  && mv hivemind /usr/local/bin

RUN git clone https://github.com/varnish/varnish-modules.git /tmp/vm && \
    cd /tmp/vm && \
    ./bootstrap && \
    ./configure && \
    make && \
    make check && \
    make install

WORKDIR /app

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

COPY . .
COPY default.vcl /etc/varnish/default.vcl
COPY Procfile Procfile

RUN chmod +x /usr/local/bin/hivemind
RUN chmod +x /app/scripts/*.sh

EXPOSE 3000 8080
ENV PORT=3000

RUN ["chmod", "+w", "/dev/stdout"]

CMD ["/usr/local/bin/hivemind"]