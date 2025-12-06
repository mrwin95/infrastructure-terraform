import Redis, { Redis as RedisClient, RedisOptions } from "ioredis";
import * as fs from "fs";
import { config } from "./config/config";

let client: RedisClient | null = null;

export const createValkeyClient = (): RedisClient => {
  if (client) return client;

  const options: RedisOptions = {
    host: config.host,
    port: config.port,
    keyPrefix: config.keyPrefix ?? "",
    lazyConnect: true,
  };

  if (config.useTls) {
    const caPath = process.env.VALKEY_CA_PATH;
    options.tls = caPath
      ? {
          ca: [fs.readFileSync(caPath)],
        }
      : {};
  }

  client = new Redis(options);
  client.on("connect", () => {
    console.log("valkey connected");
  });
  client.on("error", (err) => {
    console.log("valkey Error: ", err);
  });

  client.on("close", () => {
    console.log("valkey closed");
  });

  return client;
};

export const pingValkey = async (): Promise<void> => {
  const c = createValkeyClient();
  await c.connect();
  const pong = await c.ping();
  console.log("valkey PING -> ", pong);
};

export const demoSetGet = async (): Promise<void> => {
  const c = createValkeyClient();
  await c.connect();

  const key = "demo:key";
  const value = new Date().toISOString();

  await c.set(key, value, "EX", 60);
  console.log(`key set ${key} = ${value}`);

  const loaded = await c.get(key);
  console.log(`GET ${key} -> `, loaded);
};
