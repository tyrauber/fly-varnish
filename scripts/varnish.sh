#!/bin/sh

/usr/sbin/varnishd -F -f /etc/varnish/default.vcl -a http=:8080,HTTP -a proxy=:8443,PROXY -T none &
/usr/bin/varnishncsa -w /dev/stdout -F '%{Host}i %h %l %u %t \"%r\" %s %b \"%{Referer}i\" \"%{User-agent}i\" \"%{Varnish:hitmiss}x\" \"%{x-location-latitude}i\" \"%{x-location-longitude}i\"'