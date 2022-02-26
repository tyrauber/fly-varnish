#!/bin/sh

DEFAULT_LOGS='%{Host}i %h %l %u %t \"%r\" %s %b \"%{Referer}i\" \"%{User-agent}i\" \"%{Varnish:hitmiss}x\" \"%{x-location-latitude}i\" \"%{x-location-longitude}i\"}'

/usr/sbin/varnishd -F \
  -s file,${VARNISH_STORAGE_PATH:-/data},${VARNISH_STORAGE_SIZE:-1G} \
  -f ${VARNISH_CONFIG_PATH:-/etc/varnish/default.vcl} \
  -a http=:8080,HTTP -a proxy=:8443,PROXY -T none &
/usr/bin/varnishncsa -w /dev/stdout -F "${VARNISH_LOG_PATH:-$DEFAULT_LOGS}"
