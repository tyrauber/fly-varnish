FROM varnish:fresh-alpine as alpine

RUN apk add --update nodejs npm
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN npm --global config set user appuser && \
  npm --global install foreman

RUN mkdir /app
RUN chown -R appuser:appgroup /app
WORKDIR /app

COPY default.vcl /etc/varnish/default.vcl
COPY . .

RUN chmod +x /app/entrypoint.sh
RUN npm install --production

EXPOSE 3000 8080 443

USER appuser
ENTRYPOINT ["sh","./entrypoint.sh", "nf", "start"]
USER root
