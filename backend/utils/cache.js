import crypto from "crypto";
import { getRedis } from "../config/redis.js";

const memoryCache = new Map();
const memoryLocks = new Map();

export const CACHE_VERSION = "v2";

export const TTL = {
  STATION_LIST: 30 * 24 * 60 * 60,
  STATION_DETAILS: 7 * 24 * 60 * 60,
  STATION_SEARCH: 30 * 24 * 60 * 60,
  STATION_CATALOG: 30 * 24 * 60 * 60,
  TRAIN_SCHEDULE: 24 * 60 * 60,
  BETWEEN_STATIONS: 10 * 60,
  STATION_BOARD: 60,
  LIVE_TRAIN: 20,
  COACH_POSITION: 7 * 24 * 60 * 60,
  PNR: 2 * 60,
  BRV1_COOKIE: 60 * 60,
  GEO: 30 * 24 * 60 * 60,
  PROFILE: 5 * 60,
};

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

export function cacheKey(...parts) {
  return [CACHE_VERSION, ...parts].filter((p) => p != null && p !== "").join("_");
}

export async function cacheGet(key) {
  const redis = getRedis();
  if (redis) {
    try {
      const val = await redis.get(key);
      return val ? JSON.parse(val) : null;
    } catch (err) {
      console.warn("Redis GET failed:", err.message);
    }
  }

  const entry = memoryCache.get(key);
  if (!entry) return null;
  if (Date.now() > entry.expiresAt) {
    memoryCache.delete(key);
    return null;
  }
  return entry.data;
}

export async function cacheSet(key, data, ttlSeconds) {
  const redis = getRedis();
  if (redis) {
    try {
      await redis.setEx(key, ttlSeconds, JSON.stringify(data));
      return;
    } catch (err) {
      console.warn("Redis SET failed:", err.message);
    }
  }

  memoryCache.set(key, {
    data,
    expiresAt: Date.now() + ttlSeconds * 1000,
  });
}

export async function cacheDelete(key) {
  const redis = getRedis();
  if (redis) {
    try {
      await redis.del(key);
    } catch (err) {
      console.warn("Redis DEL failed:", err.message);
    }
  }
  memoryCache.delete(key);
}

export async function cacheDeletePattern(pattern) {
  const redis = getRedis();
  if (redis) {
    try {
      let cursor = "0";
      do {
        const result = await redis.scan(cursor, { MATCH: pattern, COUNT: 100 });
        cursor = result.cursor;
        if (result.keys.length > 0) {
          await redis.del(result.keys);
        }
      } while (cursor !== "0");
    } catch (err) {
      console.warn("Redis SCAN/DEL failed:", err.message);
    }
  }

  const prefix = pattern.replace(/\*/g, "");
  for (const key of memoryCache.keys()) {
    if (key.includes(prefix)) {
      memoryCache.delete(key);
    }
  }
}

async function acquireLock(lockKey, ttlSeconds = 15) {
  const redis = getRedis();
  if (redis) {
    try {
      const acquired = await redis.set(lockKey, "1", { NX: true, EX: ttlSeconds });
      return acquired === "OK";
    } catch {
      return false;
    }
  }

  if (memoryLocks.has(lockKey)) return false;
  memoryLocks.set(lockKey, Date.now() + ttlSeconds * 1000);
  return true;
}

async function releaseLock(lockKey) {
  const redis = getRedis();
  if (redis) {
    try {
      await redis.del(lockKey);
    } catch {
      /* ignore */
    }
  }
  memoryLocks.delete(lockKey);
}

/** Prevents cache stampede: only one fetcher populates Redis on miss. */
export async function cacheGetOrSet(key, ttlSeconds, fetchFn, { shouldCache } = {}) {
  const cached = await cacheGet(key);
  if (cached !== null) return cached;

  const lockKey = `lock_${key}`;
  const acquired = await acquireLock(lockKey);

  if (!acquired) {
    for (let i = 0; i < 30; i++) {
      await sleep(100);
      const retry = await cacheGet(key);
      if (retry !== null) return retry;
    }
  }

  try {
    const again = await cacheGet(key);
    if (again !== null) return again;

    const fresh = await fetchFn();
    const cacheable = shouldCache ? shouldCache(fresh) : true;
    if (cacheable) {
      await cacheSet(key, fresh, ttlSeconds);
    }
    return fresh;
  } finally {
    if (acquired) await releaseLock(lockKey);
  }
}

export function generateETag(body) {
  const hash = crypto.createHash("md5").update(JSON.stringify(body)).digest("hex");
  return `"${hash}"`;
}

export function setCacheControl(res, maxAgeSeconds) {
  res.set("Cache-Control", `public, max-age=${maxAgeSeconds}`);
}

export function sendJsonWithETag(req, res, body, maxAgeSeconds, useEtag = true) {
  setCacheControl(res, maxAgeSeconds);
  if (!useEtag) {
    return res.status(200).json(body);
  }

  const etag = generateETag(body);
  res.set("ETag", etag);

  const clientEtag = req.headers["if-none-match"];
  if (clientEtag && clientEtag === etag) {
    return res.status(304).end();
  }

  return res.status(200).json(body);
}

/** Cache-aside + stampede protection + ETag in one call. */
export async function respondWithCache(req, res, { key, ttl, fetchFn, useEtag = true, shouldCache }) {
  const body = await cacheGetOrSet(key, ttl, fetchFn, { shouldCache });
  return sendJsonWithETag(req, res, body, ttl, useEtag);
}
