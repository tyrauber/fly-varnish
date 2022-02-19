FROM varnish:fresh-alpine as alpine
COPY default.vcl /etc/varnish/

RUN apk add --update nodejs npm
RUN  npm install -g foreman
WORKDIR /app

COPY package.json .
COPY package-lock.json .
RUN npm install --production
COPY . .

EXPOSE 3000 8080 443

COPY Procfile Procfile

CMD nf start