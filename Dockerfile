FROM varnish:fresh-alpine as alpine
RUN apk add --update nodejs npm curl
WORKDIR /app

COPY . .
COPY default.vcl /etc/varnish/default.vcl
RUN npm install --production

EXPOSE 3000 8080
ENV PORT=3000
RUN ["chmod", "+w", "/dev/stdout"]

ADD entrypoint.sh .
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]

CMD ["node", "server"]