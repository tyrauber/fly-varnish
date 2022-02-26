vcl 4.0;
import std;
import xkey;
import geoip2;

backend default {
  .host = "127.0.0.1";
  .port = "3000";
}

sub vcl_init {
  new city = geoip2.geoip2("/data/GeoLite2-City.mmdb");
}

sub vcl_recv {

  unset req.http.x-cache;
  unset req.http.fly-cache-status;

  set req.http.x-geo-country-iso = city.lookup("continent/code", client.ip);
  set req.http.x-continent-geonameId = city.lookup("continent/geonameId", client.ip);
  set req.http.x-continent-names-en = city.lookup("continent/names/en", client.ip);
  set req.http.x-country-geonameId = city.lookup("country/geonameId", client.ip);
  set req.http.x-country-isoCode = city.lookup("country/isoCode", client.ip);
  set req.http.x-country-names-en = city.lookup("country/names/en", client.ip);
  set req.http.x-registeredCountry-geonameId = city.lookup("registeredCountry/geonameId", client.ip);
  set req.http.x-registeredCountry-isoCode = city.lookup("registeredCountry/isoCode", client.ip);
  set req.http.x-registeredCountry-names-en = city.lookup("registeredCountry/names/en", client.ip);
  set req.http.x-registeredCountry-isInEuropeanUnion = city.lookup("registeredCountry/isInEuropeanUnion", client.ip);
  set req.http.x-traits-isAnonymous = city.lookup("traits/isAnonymous", client.ip);
  set req.http.x-traits-isAnonymousProxy = city.lookup("traits/isAnonymousProxy", client.ip);
  set req.http.x-traits-isHostingProvider = city.lookup("traits/isHostingProvider", client.ip);
  set req.http.x-traits-isLegitimateProxy = city.lookup("traits/isLegitimateProxy", client.ip);
  set req.http.x-traits-isPublicProxy = city.lookup("traits/isPublicProxy", client.ip);
  set req.http.x-traits-isResidentialProxy = city.lookup("traits/isResidentialProxy", client.ip);
  set req.http.x-traits-isSatelliteProvider = city.lookup("traits/isSatelliteProvider", client.ip);
  set req.http.x-traits-isTorExitNode = city.lookup("traits/isTorExitNode", client.ip);
  set req.http.x-traits-ipAddress = city.lookup("traits/ipAddress", client.ip);
  set req.http.x-traits-network = city.lookup("traits/network", client.ip);
  set req.http.x-city-geonameId = city.lookup("city/geonameId", client.ip);
  set req.http.x-city-name = city.lookup("city/name/en", client.ip);
  set req.http.x-location-accuracyRadius = city.lookup("location/accuracyRadius", client.ip);
  set req.http.x-location-latitude = city.lookup("location/latitude", client.ip);
  set req.http.x-location-longitude = city.lookup("location/longitude", client.ip);
  set req.http.x-location-metroCode = city.lookup("location/metroCode", client.ip);
  set req.http.x-location-timeZone = city.lookup("location/timeZone", client.ip);
  set req.http.x-postal-code = city.lookup("postal/code", client.ip);
  set req.http.x-subdivisions-geonameId = city.lookup("subdivisions/geonameId", client.ip);
  set req.http.x-subdivisions-isoCode = city.lookup("subdivisions/isoCode", client.ip);
  # # FAILS: set req.http.x-subdivisions-names-en = city.lookup("subdivisions/names/en", client.ip);

  if (req.method == "PURGE") {
    if (req.http.xkey) {
      set req.http.n-gone = xkey.purge(req.http.xkey);
      # or: set req.http.n-gone = xkey.softpurge(req.http.xkey)
      return (synth(200, "Invalidated "+req.http.n-gone+" objects"));
    } else {
      return (purge);
    }
  }
}

sub vcl_hit {
  set req.http.fly-cache-status = "HIT";
  set req.http.x-cache = "hit";
}

sub vcl_miss {
  set req.http.fly-cache-status = "MISS";
  set req.http.x-cache = "miss";
}

sub vcl_pass {
  set req.http.fly-cache-status = "PASS";
  set req.http.x-cache = "pass";
}

sub vcl_pipe {
  set req.http.x-cache = "pipe uncacheable";
}

sub vcl_synth {
  set req.http.x-cache = "synth synth";
  set resp.http.x-cache = req.http.x-cache;
  set resp.http.fly-cache-status = req.http.fly-cache-status;
}

sub vcl_deliver {
  if (obj.uncacheable) {
      set req.http.x-cache = req.http.x-cache + " uncacheable" ;
  } else {
      set req.http.x-cache = req.http.x-cache + " cached" ;
  }
  set resp.http.x-cache = req.http.x-cache;
  set resp.http.fly-cache-status = req.http.fly-cache-status;

  set resp.http.x-geo-country-iso = req.http.x-geo-country-iso;
  set resp.http.x-continent-geonameId = req.http.x-continent-geonameId;
  set resp.http.x-continent-names-en = req.http.x-continent-names-en;
  set resp.http.x-country-geonameId = req.http.x-country-geonameId;
  set resp.http.x-country-isoCode = req.http.x-country-isoCode;
  set resp.http.x-country-names-en = req.http.x-country-names-en;
  # set resp.http.x-registeredCountry-geonameId = req.http.x-registeredCountry-geonameId;
  # set resp.http.x-registeredCountry-isoCode = req.http.x-registeredCountry-isoCode;
  # set resp.http.x-registeredCountry-names-en = req.http.x-registeredCountry-names-en;
  set resp.http.x-registeredCountry-isInEuropeanUnion = req.http.x-registeredCountry-isInEuropeanUnion;
  # set resp.http.x-traits-isAnonymous = req.http.x-traits-isAnonymous;
  # set resp.http.x-traits-isAnonymousProxy = req.http.x-traits-isAnonymousProxy;
  # set resp.http.x-traits-isHostingProvider = reqhttp..x-traits-isHostingProvider;
  # set resp.http.x-traits-isLegitimateProxy = req.http.x-traits-isLegitimateProxy;
  # set resp.http.x-traits-isPublicProxy = req.http.x-traits-isPublicProxy;
  # set resp.http.x-traits-isResidentialProxy = req.http.x-traits-isResidentialProxy;
  # set resp.http.x-traits-isSatelliteProvider = req.http.x-traits-isSatelliteProvider;
  # set resp.http.x-traits-isTorExitNode = req.http.x-traits-isTorExitNode;
  # set resp.http.x-traits-ipAddress = req.http.x-traits-ipAddress;
  # set resp.http.x-traits-network = req.http.x-traits-network;
  set resp.http.x-city-geonameId = req.http.x-city-geonameId;
  set resp.http.x-city-name = req.http.x-city-name;
  # set resp.http.x-location-accuracyRadius = req.http.x-location-accuracyRadius;
  set resp.http.x-location-latitude = req.http.x-location-latitude;
  set resp.http.x-location-longitude = req.http.x-location-longitude;
  set resp.http.x-location-metroCode = req.http.x-location-metroCode;
  set resp.http.x-location-timeZone = req.http.x-location-timeZone;
  set resp.http.x-postal-code = req.http.x-postal-code;
  # set resp.http.x-subdivisions-geonameId = req.http.x-subdivisions-geonameId;
  set resp.http.x-subdivisions-isoCode = req.http.x-subdivisions-isoCode;
  # set resp.http.x-subdivisions-names-en = req.http.x-subdivisions-names-en;
}