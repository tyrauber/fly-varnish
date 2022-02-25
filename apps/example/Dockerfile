FROM tyrauber/fly-varnish

WORKDIR /app
COPY package.json /app
RUN npm install 
RUN npm install esbuild-linux-arm64@0.14.22
COPY /apps/example .
RUN npm run build
