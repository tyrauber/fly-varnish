
# ---- Base Node ----

FROM varnish:fresh-alpine as base

ARG VARNISH_SIZE 100M

RUN apk add --update nodejs
RUN apk add -q \
    curl \
    git \
    gzip \
    npm \
    tar \
    sudo

COPY package.json .

# #
# # ---- Build ----

FROM base AS build

RUN curl -L https://github.com/DarthSim/hivemind/releases/download/v1.1.0/hivemind-v1.1.0-linux-amd64.gz -o hivemind.gz \
  && gunzip hivemind.gz \
  && mv hivemind /usr/local/bin

RUN git clone --branch master --single-branch https://github.com/varnish/varnish-modules.git
WORKDIR /varnish-modules
RUN ./bootstrap && \
    ./configure && \
    make && \
    make install &\
    rm -rf /varnish-modules

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