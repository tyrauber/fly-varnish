web: PORT=3000 node server.js
cdn: /usr/sbin/varnishd -F -f /etc/varnish/default.vcl -a http=:8080,HTTP -a proxy=:8443,PROXY -T localhost:6082