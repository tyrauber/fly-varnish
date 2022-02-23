const express = require("express");
const app = express();
const port = process.env.PORT || 3000;

app.get(["/", "/:name"], (req, res) => {
  let fullUrl = req.protocol + '://' + req.get('host') + req.originalUrl;
  let now = Math.round(new Date().getTime() / 1000)
  let name = req.params?.["name"];
  html = `<h1>${['Hello', name].filter(e =>  e).join(', ')}!</h1>`;
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

app.listen(port, () => console.log(`HelloNode app listening on port ${port}!`));
