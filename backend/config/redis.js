import { createClient } from "redis";

let client = null;
let connected = false;

export const connectRedis = async () => {
  const url = process.env.REDIS_URL;
  if (!url) {
    console.warn("REDIS_URL not set — using in-memory cache fallback");
    return null;
  }

  try {
    client = createClient({ url });
    client.on("error", (err) => {
      console.error("Redis error:", err.message);
      connected = false;
    });
    await client.connect();
    connected = true;
    console.log("Redis connected");
    return client;
  } catch (err) {
    console.warn("Redis unavailable — using in-memory cache fallback:", err.message);
    client = null;
    connected = false;
    return null;
  }
};

export const getRedis = () => (connected && client ? client : null);
