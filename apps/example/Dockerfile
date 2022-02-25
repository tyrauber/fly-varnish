FROM docker.io/tyrauber/fly-varnish

WORKDIR /app
COPY package.json /app
RUN npm install 
COPY . .
RUN npm run build
