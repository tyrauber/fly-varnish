const express = require("express");
const app = express();
const port = process.env.PORT || 3000;

app.get(["/", "/:name"], (req, res) => {
  let now = Math.round(new Date().getTime() / 1000)
  greeting = `<h1>Hello From Node on Fly! (${now})</h1>`;
  name = req.params["name"];
  res.set('xKey', now);
  if (name) {
    res.send(greeting + "</br>and hello to " + name);
  } else {
    res.send(greeting);
  }
});

app.listen(port, () => console.log(`HelloNode app listening on port ${port}!`));
