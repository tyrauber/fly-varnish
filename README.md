# fly-varnish
A varnish docker image for caching, purging and logging services on Fly.io.

## Features

  - Alpine:Latest Docker Container (~ 230Mb)
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
  - [libvmod-geoip2](https://github.com/fgsch/libvmod-geoip2): MaxMind GeoIP2 Geolocation.


## Usage

 - Clone the Repo: `git clone github.com/tyrauber/fly-varnish`
 - Build the docker container: `npm run docker:build`
 - Run app locally: `npm run docker:test`
 - Open `http://localhost:8080`

## Features

  - Alpine:Latest Docker Container (~ 230Mb)
  - Varnish 7.0.2
  - [Varnish Modules](https://github.com/varnish/varnish-modules)
    + 
  - [libvmod-geoip2](https://github.com/fgsch/libvmod-geoip2)

```
$ curl -I http://localhost:8080
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: text/html; charset=utf-8
Content-Length: 37
ETag: W/"25-UdrQNs2x6rJSM6iMoU5gLAgy3pQ"
Date: Sat, 19 Feb 2022 14:24:55 GMT
X-Varnish: 65541
Age: 0
Via: 1.1 varnish (Varnish/7.0)
Accept-Ranges: bytes
x-cache: miss cached
Connection: keep-alive
```

Awesome!

## Fly launch

Sign up for Fly.io and deploy:

`fly launch`

Now let's curl from the Fly App:

```
$ curl -I https://app_name.fly.dev/
HTTP/2 200 
x-powered-by: Express
content-type: text/html; charset=utf-8
content-length: 32
etag: W/"20-jOVk+DeeZmEt1wO5PpDKHSGXcfE"
date: Sun, 20 Feb 2022 19:18:34 GMT
x-varnish: 5 3
age: 32
via: 1.1 varnish (Varnish/7.0), 2 fly.io
accept-ranges: bytes
x-cache: hit cached
server: Fly/90620415 (2022-02-19)
fly-request-id: 01FWC95HZVBZ62QEE2AMC4BWD9-mia
```

And check the logs:

```
$ fly logs
2022-02-20T19:16:13Z runner[c581869e] mia [info]Starting instance
2022-02-20T19:16:13Z runner[c581869e] mia [info]Configuring virtual machine
2022-02-20T19:16:13Z runner[c581869e] mia [info]Pulling container image
2022-02-20T19:16:15Z runner[c581869e] mia [info]Unpacking image
2022-02-20T19:16:17Z runner[c581869e] mia [info]Preparing kernel init
2022-02-20T19:16:18Z runner[c581869e] mia [info]Configuring firecracker
2022-02-20T19:16:19Z runner[c581869e] mia [info]Starting virtual machine
2022-02-20T19:16:19Z app[c581869e] mia [info]Starting init (commit: 0c50bff)...
2022-02-20T19:16:19Z app[c581869e] mia [info]Preparing to run: `/app/entrypoint.sh node server` as root
2022-02-20T19:16:19Z app[c581869e] mia [info]2022/02/20 19:16:19 listening on [fdaa:0:4cc2:a7b:2c01:c581:869e:2]:22 (DNS: [fdaa::3]:53)
2022-02-20T19:16:19Z app[c581869e] mia [info]HelloNode app listening on port 3000!
2022-02-20T19:16:20Z app[c581869e] mia [info].Debug: Version: varnish-7.0.2 revision 9b5f68e19ca0ab60010641e305fd12822f18d42c
2022-02-20T19:16:20Z app[c581869e] mia [info]Debug: Platform: Linux,5.12.2,x86_64,-junix,-sdefault,-sdefault,-hcritbit
2022-02-20T19:16:20Z app[c581869e] mia [info]Debug: Child (539) Started
2022-02-20T19:16:20Z app[c581869e] mia [info]Info: Child (539) said Child starts
2022-02-20T19:18:34Z app[c581869e] mia [info]fly-varnish.fly.dev X.X.X.X - - [20/Feb/2022:19:18:34 +0000] "GET http://app_name.fly.dev/ HTTP/1.1" 200 32 "https://fly.io/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36" "miss"
```

And we are pushing Varnish Logs to Fly. AWESOME.

## Further Reading:

[varnishncsa](https://varnish-cache.org/docs/trunk/reference/varnishncsa.html) - Varnish Logging

Customize the log output. For exampple:
```
/usr/bin/varnishncsa -w /dev/stdout -F '%{Host}i %h %l %u %t \"%r\" %s %b \"%{Referer}i\" \"%{User-agent}i\" \"%{Varnish:hitmiss}x\"'
```

**To-do:** Pass the the output log format string (-F) in through the Procfile as an argument. Will make it customizable without having to rebuild the docker file.

[https://stackoverflow.com/a/61030478/2158127](https://stackoverflow.com/a/61030478/2158127)