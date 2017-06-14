vcl 4.0;

backend localhost {
	.host = "127.0.0.1";
	.port = "8080";
}

sub vcl_recv {
  if (req.url ~ "^/ping") {
    return (synth(200, "OK"));
  }
}

sub vcl_synth {
  if (resp.status == 200) {
    if (req.url ~ "^/ping") {
      synthetic("pong");
    }
    set resp.http.Content-Type = "text/plain; charset=utf-8";
    return (deliver);
  }
}