# fly-varnish
A Varnish Docker Container using a Forman Procfile to run and cache multiple Node processes

## Usage

 - Clone the Repo: `git clone github.com/tyrauber/fly-varnish`
 - Build the docker container: `npm run docker:build`
 - Run app locally: `npm run docker:test`
 - Open `http://localhost:8080`

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


## Further Reading:

[https://stackoverflow.com/a/61030478/2158127](https://stackoverflow.com/a/61030478/2158127)