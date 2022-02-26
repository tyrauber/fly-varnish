vcl 4.0;
import std;
import xkey;

backend default {
  .host = "127.0.0.1";
  .port = "3000";
}

sub vcl_recv {

  unset req.http.x-cache;
  unset req.http.fly-cache-status;

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
}