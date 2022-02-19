vcl 4.0;

backend default {
  .host = "127.0.0.1";
  .port = "3000";
}

sub vcl_recv {
    unset req.http.x-cache;
}

sub vcl_hit {
    set req.http.x-cache = "hit";
}

sub vcl_miss {
    set req.http.x-cache = "miss";
}

sub vcl_pass {
    set req.http.x-cache = "pass";
}

sub vcl_pipe {
    set req.http.x-cache = "pipe uncacheable";
}

sub vcl_synth {
    set req.http.x-cache = "synth synth";
    set resp.http.x-cache = req.http.x-cache;
}

sub vcl_deliver {
    if (obj.uncacheable) {
        set req.http.x-cache = req.http.x-cache + " uncacheable" ;
    } else {
        set req.http.x-cache = req.http.x-cache + " cached" ;
    }
    set resp.http.x-cache = req.http.x-cache;
}