FROM varnish:fresh-alpine as alpine
RUN apk add --update nodejs npm
WORKDIR /app

COPY default.vcl /etc/varnish/default.vcl
COPY package.json .
COPY package-lock.json .
RUN npm install --production

COPY . .
EXPOSE 3000 8080
CMD [ "node","server.js" ]
