// Demonstracyjny kontener subskrybenta.
//
// subscriber/index.js
//

process.env.DEBUG = "subscriber";

const debug = require("debug")("subscriber"),
  mongo_host = process.env.MONGO_HOST || "mongodb",
  mongo_port = 27017,
  mongoUrl = `mongodb://${mongo_host}:${mongo_port}`,
  mqtt_host = process.env.MQTT_HOST || "mosca",
  mqtt_port = 1883,
  mqttUrl = `mqtt://${mqtt_host}`,
  redis_host = process.env.REDIS_HOST || "redis",
  redis_port = 6379,
  redisUrl = `redis://${redis_host}`;

/**
 * wait_for_services
 *
 * Metoda wywoływana po uruchomieniu aplikacji, oczekująca na uruchomienie zależnych kontenerów.
 */
const waitOn = require("wait-on"),
  wait_for_services = async () => {
  try {
    debug(`waiting for mqtt (${mqtt_host}:${mqtt_port})`);
    await waitOn({ resources: [`tcp:${mqtt_host}:${mqtt_port}`] });
    debug(`waiting for redis (${redis_host}:${redis_port})`);
    await waitOn({ resources: [`tcp:${redis_host}:${redis_port}`] });
    debug(`waiting for mongo (${mongo_host}:${mongo_port})`);
    await waitOn({ resources: [`tcp:${mongo_host}:${mongo_port}`] });
  } catch (e) {
    debug("***** Wyjątek ", e.stack);
  }
};

const main = async () => {
  debug("Oczekiwanie na usługi");
  await wait_for_services();
  debug("  Koniec oczekiwania");
  // Uwaga: do kontenerów mosca, redis u mongodb odwołujemy się po nazwie.
  const MongoClient = require("mongodb").MongoClient,
    mongoDB = "book",
    mongo = new MongoClient(mongoUrl),
    MQTT = require("mqtt");

  var Redis = require("async-redis"),
    redis = Redis.createClient(redisUrl),
    redis_index = 0;

  redis.on("error", function(err) {
    debug("Błąd REDIS" + err);
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
      return keys.length;
    },

    "subscriber/redis-flushall": async (collection, message) => {
      // Wyczyszczenie bazy.
      debug("--- redis flushall '" + message + "'");
      const keys = await redis.flushall();
      debug("flushall", keys);
      redis_index = 0;
      return keys;
    },

    "subscriber/redis-set": async (collection, message) => {
      // Dodanie rekordu do bazy Redis.
      const parts = message.split(~message.indexOf("=") ? "=" : " ");
      if (parts.length === 1) {
        redis_index++;
        parts.unshift("text" + redis_index);
      }
      parts[1] = JSON.stringify({ text: parts[1] });
      debug("--- redis add", message, parts);
      return await redis.set(parts);
    },

    "subscriber/redis-list": async (collection, message) => {
      // Odczytanie tablicy rekordów z bazy Redis. 
      debug("redis-list", message);
      const keys = await redis.keys(message || "*");
      debug("--- redis list", message, keys);
      const result = [];
      for (const key of keys) {
        result.push(JSON.parse(await redis.get(key)));
      }

      return result;
    },

    "subscriber/redis-del": async (collection, message) => {
      // Usunięcie rekordu z bazy Redis.
      debug("redis-del", message);
      const message2 = JSON.stringify({ text: message });
      const keys = await redis.keys("*");
      for (const key of keys) {
        const val = await redis.get(key);
        if (val === message || val === message2) {
          return await redis.del(key);
        }
      }
      return "Nie znaleziono";
    },

    "subscriber/commands": async (collection, message) => {
      debug("--- COMMANDS", message);
      return JSON.stringify(Object.keys(topics));
    }
  };

  // Metoda connect łącząca się z serwerem.
  debug("Łączenie z serwerem MongoDB", mongoUrl);
  mongo.connect(function(err) {
    if (err) {
      debug("Błąd połączenia z bazą MongoDB:", err);
      return;
    }
    debug("Połączony z sewerem bazy MongoDB", mongoUrl);
    debug("\n");

    const db = mongo.db(mongoDB);

    debug("Łączenie z brokerem MQTT", mqttUrl, mqtt_port);
    const mqtt = MQTT.connect(mqttUrl, mqtt_port);
    mqtt.on("connect", () => {
      debug("Połączony z ", mqttUrl, "port", mqtt_port);
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
        } catch (e) {
          // Nie rób nic.
        }
        debug("<<< temat", topic, "treść", message);
        const f = topics[topic];
        if (f !== undefined) {
          try {
            const msg = await f(db.collection("records"), message);
            if (msg !== undefined) {
              const new_topic = topic.replace("subscriber", "publisher");
              debug("  >>> temat: ", new_topic, "treść:", msg);
              await mqtt.publish(
                topic.replace("subscriber", "publisher"),
                JSON.stringify(msg),
                { qos: 0, retain: false }
              );
            }
          } catch (e) {
            debug("Wyjątek", topic, message, e.stack);
          }
        }
      });
    });
  });
};

main();
