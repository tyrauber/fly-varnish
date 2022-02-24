# fly-varnish
A varnish docker image for caching, purging and logging requests on Fly.io.

## About

Although this docker image can be used anywhere, it is **built** for Fly.io.  Fly.io is an awesome service that enables easy deployment of web services all over the world, at the edge of the network, close to users everywhere.  It's blazing fast, has a great API, is easy to use and quite affordable.

This docker image is intended to make the most of the Fly.io infrastructure.

## Usage

For these examples we are going to use [Remix](https:///remix.run) because Remix is also awesome!

**Simple example:**

Create a remix express app.

```
$ npx create-remix@latest
# IMPORTANT: Choose "Express Server" when prompted
cd [whatever you named the project]

```

[Install Flyctl](https://fly.io/docs/getting-started/installing-flyctl/) - you'll need it.

Create an account with `flyctl auth` signup or login with `flyctl auth` login.

```
$ fly launch
# name your project, but choose not to install a postgres database or deploy

```

Create the following `Dockfile`:

```
FROM fly-varnish
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
```

That's it. Deploy.

```
$ fly deploy
$ fly open
```

You should see the default Remix page, and if you curl the address from the console:

```
$ curl -I https://[whatever you named the project].fly.dev
```

You should see some Varnish related headers!

```
xkey: 1645744861
x-varnish: 32958 194
age: 9
via: 1.1 varnish (Varnish/7.0), 2 fly.io
x-cache: hit cached
```

### Advanced Usage

**+ Custom Procfile**

Under the covers, the Docker image uses [Hivemind](https://github.com/DarthSim/hivemind), a Procfile process manager, to run services.

The default is:
```
varnish: ./varnish.sh
dashboard: PORT=8000 ./dashboard.sh
web: PORT=3000 npm start
```
But you can create your own `Procfile`, and as long as it is in your root project directory, `COPY . .` will copy it to the right place! Enjoy many infinite services.

**+ Custom VCL**

The default default VCL:

- sets the default backend to 127.0.0.1:3000
- sets the `fly-cache-status` header to power Fly.io's HTTP Cache Ratio
- sets some xKey purging

geoip2 is installed on the docker container but requires a MaxMind Login to download the data. GeoLite2-City.mmdb should be downloaded to the /data directory. Then the appropriate changes to the VCL can be made:

```
sub vcl_init {
  new city = geoip2.geoip2("/data/GeoLite2-City.mmdb");
}
```

To use a custom VCL your Dockerfile must copy it to the appropriate location.

```
COPY default.vcl /etc/varnish/default.vcl
```

**+ varnish**

Varnish is started by an .sh file

```
/usr/sbin/varnishd -F -f /etc/varnish/default.vcl -a http=:8080,HTTP -a proxy=:8443,PROXY -T none &
/usr/bin/varnishncsa -w /dev/stdout -F '%{Host}i %h %l %u %t \"%r\" %s %b \"%{Referer}i\" \"%{User-agent}i\" \"%{Varnish:hitmiss}x\"'
```

The first line starts Varnish with the appropriate settings, the second line logs Varnish requests to /dev/stdout... and Fly.io.

You can customize the Varnish settings and log output by creating and editing a file called `varnish.sh` in your root directory.

## About the Docker Image

  - NodeJS
  - Alpine:Latest Docker Container (~ 230Mb)
  - [Hivemind](https://github.com/DarthSim/hivemind), a Procfile process manager,
  - Varnish 7.0.2
  - [Varnish Modules](https://github.com/varnish/varnish-modules)
    + [accept](https://github.com/varnish/varnish-modules/blob/master/src/vmod_accept.vcc): Filter accept-like headers
    + [bodyaccess](https://github.com/varnish/varnish-modules/blob/master/src/vmod_bodyaccess.vcc): Client request body access
    + [header](https://github.com/varnish/varnish-modules/blob/master/src/vmod_header.vcc): Modify and change complex HTTP headers
    + [saintmode](https://github.com/varnish/varnish-modules/blob/master/src/vmod_saintmode.vcc): 3.0-style saint mode
    + [str](https://github.com/varnish/varnish-modules/blob/master/src/vmod_str.vcc): String operations
    + [tcp](https://github.com/varnish/varnish-modules/blob/master/src/vmod_tcp.vcc): TCP connections tweaking
    + [var](https://github.com/varnish/varnish-modules/blob/master/src/vmod_var.vcc): Variable support
    + [vsthrottle](https://github.com/varnish/varnish-modules/blob/master/src/vmod_vsthrottle.vcc): Request and bandwidth throttling
    + [xkey](https://github.com/varnish/varnish-modules/blob/master/src/vmod_xkey.vcc): Advanced cache invalidations
  - [libvmod-geoip2](https://github.com/fgsch/libvmod-geoip2): MaxMind GeoIP2 Geolocation
 

## Further Reading:

[varnishncsa](https://varnish-cache.org/docs/trunk/reference/varnishncsa.html) - Varnish Logging

Customize the log output. For exampple:
```
/usr/bin/varnishncsa -w /dev/stdout -F '%{Host}i %h %l %u %t \"%r\" %s %b \"%{Referer}i\" \"%{User-agent}i\" \"%{Varnish:hitmiss}x\"'
```
