const express = require("express");
const Redis = require("ioredis");
const app = express();
const port = process.env.PORT || 3000;

const REDIS_URL = `redis://x:${process.env.REDIS_PASSWORD}@127.0.0.1:6379`;
console.log(REDIS_URL)
const sub = new Redis(REDIS_URL);
const pub = new Redis(REDIS_URL);

sub.psubscribe(["cache-?"], (err, count) => {
  if (err) {
    console.error("Failed to subscribe: %s", err.message);
  } else {
    console.log(
      `Subscribed successfully! This client is currently subscribed to ${count} channels.`
    );
  }
});

sub.on("pmessage", (pattern, channel, message) => {
  console.log(`Received ${message} from ${channel}`);
});

app.all('*', (req, res, next) => {
  const channel = `cache-${1 + Math.round(Math.random())}`;
  pub.publish(channel, JSON.stringify(req.headers))
  if (req.method == 'GET') {
    // ADD Key
  } else if (req.method === 'POST'){
    // Update Key, Value
  } else if (['DELETE', 'POST'].includes(req.method)){
    // Expire Key
  }
  next()
})


app.all("*", (req, res) => {
  let fullUrl = req.protocol + '://' + req.get('host') + req.originalUrl;
  let now = Math.round(new Date().getTime() / 1000)
  html = `<h1>Hello,</h1>`;
  html += `<p>This page is served by Express, cached by Varnish, and hosted on Fly.io.</p>`;
  html += `<p>Varnish 7.0.2 is compiled from source with Varnish Modules, including XKey.</p>`;
  html += `<p>If you curl this page, (curl -I ${fullUrl}), you will see the following response headers:<br/><br/>
    <b>xKey:</b> ${now}<br/>
    <b>x-cache:</b> hit cached</p>`;
  html += `<p>Refreshing the page will not update the timestamp (${now}).`
  html += `<p>You can purge this page cache with method purge, (curl -X PURGE ${fullUrl} -H "xkey: ${now}").`
  res.set('xKey', now);
  res.send(html);
});

app.listen(port, () => console.log(`Dashboard listening on port ${port}!`));