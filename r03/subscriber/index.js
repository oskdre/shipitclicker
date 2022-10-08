// Demonstracyjny kontener subskrybenta.
//
// subscriber/index.js
//

process.env.DEBUG = "subscriber";

const debug = require("debug")("subscriber"),
  MongoClient = require("mongodb").MongoClient,
  mongoUrl = `mongodb://${process.env.HOSTIP}:27017`,
  mongoDB = "book",
  mongo = new MongoClient(mongoUrl),
  MQTT = require("mqtt"),
  mqttHost = `mqtt://${process.env.HOSTIP}`,
  mqttPort = 1883,
  redisHost = `redis://${process.env.HOSTIP}`;

var Redis = require("async-redis"),
  redis = Redis.createClient(redisHost);

// Aby wybrać bazę 3, a nie 0 (domyślną), wywołaj funkcję
// client.select(3, function() { /* ... */ });

redis.on("error", function(err) {
  debug("Błąd bazy REDIS" + err);
});

const topics = {
  "subscriber/mongo-count": async (collection, message) => {
    // Odczytanie liczby rekordów w bazie MongoDB.
    debug("--- mongodb count", message);
    if ((typeof message).toLowerCase() === "string") {
      const record = { text: message };
      const records = await collection.find(record).toArray();
      return records.length;
    } else {
      const records = await collection.find(message).toArray();
      return records.length;
    }
  },

  "subscriber/mongo-add": async (collection, message) => {
    // Dodanie rekordu do bazy.
    debug("--- mongodb add", message);
    const record = [{ text: message }];
    return await collection.insertMany(record);
  },

  "subscriber/mongo-list": async (collection, message) => {
    // Odczytanie z bazy dokumentu wskazanego w komunikacie.
    // Komunikat jest obiektem JSON.
    if ((typeof message).toLowerCase() === "string") {
      // Przefiltrowanie zwróconych rekordów.
      const record = { text: message };
      const records = await collection.find(record).toArray();
      return records;
    } else {
      // Zwrócenie wszystkich rekordów.
      const records = await collection.find(message).toArray();
      return records;
    }
  },

  "subscriber/mongo-remove": async (collection, message) => {
    // Usunięcie rekordu z bazy.
    debug("--- mongodb remove", message);
    if ((typeof message).toLowerCase() === "string") {
      const record = { text: message };
      const result = await collection.deleteOne(record);
      return result.result;
    } else {
      const result = await collection.deleteOne(message);
      return result.result;
    }
  },

  "subscriber/mongo-removeall": async (collection, message) => {
    // Usunięcie wszystkich rekordów z bazy.
    debug("--- mongodb removeall", message);
    const result = await collection.remove({});
    return result;
  },

  "subscriber/redis-count": async (collection, message) => {
    // Odczytanie liczby rekordów w bazie Redis.
    debug("--- redis count '" + message + "'");
    const keys = await redis.keys(message || "*");
    //    debug("records", records);
    return keys.length;
  },

  "subscriber/redis-flushall": async (collection, message) => {
    // Wyczyszczenie bazy.
    debug("--- redis flushall '" + message + "'");
    const keys = await redis.flushall();
    debug("flushall", keys);
  },

  "subscriber/redis-set": async (collection, message) => {
    // Dodanie rekordu do bazy Redis.
    const parts = message.split(~message.indexOf("=") ? "=" : " ");
    debug("--- redis add", message, parts);
    return await redis.set(parts);
    //    return await redis.set(["hash key2", message]);
  },

  "subscriber/redis-list": async (collection, message) => {
    // Odczytanie tablicy rekordów z bazy Redis. 
    const keys = await redis.keys(message || "*");
    debug("--- redis list", message, keys);
    const result = {};
    for (const key of keys) {
      result[key] = await redis.get(key);
    }

    return result;
  },

  "subscriber/redis-del": async (collection, message) => {
    // Usunięcie rekordu z bazy Redis.
    debug("--- redis remove", message);
    return await redis.del(message);
  },

  "subscriber/commands": async (collection, message) => {
    debug("--- COMMANDS", message);
    return JSON.stringify(Object.keys(topics));
  }
};

// Połączenie z serwerem za pomocą metody connect.
debug("Łączenie z bazą MongoDB", mongoUrl);
mongo.connect(function(err) {
  if (err) {
    debug("Błąd połączenia z bazą MongoDB:", err);
    process.exit(1);
  }
  debug("Połączony z sewerem bazy MongoDB", mongoUrl);
  debug("\n");

  const db = mongo.db(mongoDB);

  debug("Łączenie z brokerem MQTT", mqttHost, mqttPort);
  const mqtt = MQTT.connect(mqttHost, mqttPort);
  mqtt.on("connect", () => {
    debug("Połączony z ", mqttHost, "port", mqttPort);
    debug("\n");
    debug("Oczekiwanie na komunikat od nadawcy");
    mqtt.subscribe("subscriber/#", err => {
      if (err) {
        debug("Błąd subskrypcji MQTT:", err);
      }
    });

    mqtt.on("message", async (topic, message) => {
      message = message.toString();
      try {
        message = JSON.parse(message);
      } catch (e) {}
      debug("<<< Temat", topic, "treść", message);
      const f = topics[topic];
      if (f !== undefined) {
        const msg = await f(db.collection("records"), message);
        if (msg !== undefined) {
          const new_topic = topic.replace("subscriber", "publisher");
          debug("  >>> Temat: ", new_topic, "treść:", msg);
          await mqtt.publish(
            topic.replace("subscriber", "publisher"),
            JSON.stringify(msg),
            { qos: 0, retain: false }
          );
        }
      }
    });
  });
});
