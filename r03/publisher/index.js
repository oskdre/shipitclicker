// Demonstracyjny kontener nadawcy.
//
// publisher/index.js
//

process.env.DEBUG = "publisher,mqtt-traffic";

const debug = require("debug")("publisher"),
  debugm = require("debug")("mqtt-traffic"),
  MQTT = require("mqtt"),
  host = `mqtt://${process.env.HOSTIP}`,
  port = 1883,
  client = MQTT.connect(host, port);

client.on("connect", () => {
  debug("Łączenie z hostem ", host, "port", port);
  debug("\n\nWysłanie komunikatu MQTT z tematem publisher i dowolną treścią.");

  client.subscribe(["publisher", "publisher/#"], err => {
    if (err) {
      debug("err!", err);
    }
  });

  client.on("message", async (topic, message) => {
    message = message.toString();
    debugm("<<< Temat komunikatu", topic, "treść", message);
    const index = topic.indexOf("publisher/");
    if (index !== -1) {
      debug("wynik", topic.substr(10), "=", JSON.parse(message));
      return;
    }
    const parts = message.split(" ");
    const new_topic = `subscriber/${parts[0]}`;
    debugm(" >>> Temat", new_topic, "treść", parts[1]);
    const t = parts.shift();
    await client.publish(`subscriber/${t}`, JSON.stringify(parts.join(" ")), {
      qos: 0,
      retain: false
    });
  });
});
