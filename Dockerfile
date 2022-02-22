FROM varnish:fresh-alpine as alpine
RUN apk add --update nodejs npm curl
WORKDIR /app

COPY . .
COPY default.vcl /etc/varnish/default.vcl
RUN npm install --production

RUN curl -L https://github.com/DarthSim/hivemind/releases/download/v1.1.0/hivemind-v1.1.0-linux-amd64.gz -o hivemind.gz \
  && gunzip hivemind.gz \
  && mv hivemind /usr/local/bin

WORKDIR /app

EXPOSE 3000 8080
ENV PORT=3000
RUN ["chmod", "+w", "/dev/stdout"]

COPY Procfile Procfile
COPY . .
RUN chmod +x /usr/local/bin/hivemind
RUN chmod +x /app/scripts/*.sh

CMD ["/usr/local/bin/hivemind"]