import axios from "axios";
import { localStations } from "../utils/localization.js";
import { cacheGetOrSet, cacheKey, TTL } from "../utils/cache.js";

const POPULAR_TRAINS = [
  "12951", "12627", "12259", "12301", "12431", "12842", "22691",
  "12009", "12952", "12302", "12260", "12432", "12841", "22692",
];

const POPULAR_STATIONS = [
  "NDLS", "CSMT", "NGP", "HWH", "SBC", "MAS", "BCT", "PUNE",
  "LKO", "CNB", "JP", "ADI", "BBS", "SC", "TVC", "ASR",
];

const REDBUS_HEADERS = {
  "accept": "application/json, text/plain, */*",
  "accept-language": "en-US,en;q=0.9",
  "User-Agent":
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
};

// Increased to 30s — Render cold-start + redbus latency can be high
const FETCH_TIMEOUT_MS = 30000;
// Delay between each train fetch to avoid rate-limiting
const FETCH_DELAY_MS = 500;
// Concurrent batch size
const BATCH_SIZE = 3;

async function fetchWithRetry(url, retries = 2) {
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      const response = await axios.get(url, {
        headers: REDBUS_HEADERS,
        timeout: FETCH_TIMEOUT_MS,
      });
      return response.data;
    } catch (err) {
      const isLast = attempt === retries;
      if (isLast) throw err;
      // Exponential back-off: 1s, 2s …
      await new Promise((r) => setTimeout(r, 1000 * attempt));
    }
  }
}

async function warmLiveTrain(trainNo) {
  const key = cacheKey("live", trainNo, "en");
  await cacheGetOrSet(
    key,
    TTL.LIVE_TRAIN,
    async () => {
      const URL = `https://www.redbus.in/railways/api/getLtsDetails?trainNo=${trainNo}`;
      const data = await fetchWithRetry(URL);
      return { success: true, resData: data };
    },
    { shouldCache: (body) => body?.success === true }
  );
}

async function warmStationCatalog() {
  const key = cacheKey("station_catalog");
  await cacheGetOrSet(key, TTL.STATION_CATALOG, async () => {
    const stations = localStations
      .filter((s) => {
        const code = s.properties?.code;
        return code && !String(code).startsWith("XX") && s.properties?.name;
      })
      .map((s) => ({
        code: s.properties.code.toUpperCase(),
        name: s.properties.name,
        state: s.properties.state || "",
      }));
    return { success: true, stations, count: stations.length, version: 2 };
  });
}

// Run an array of async tasks in batches of `size`
async function runInBatches(items, size, fn) {
  for (let i = 0; i < items.length; i += size) {
    const batch = items.slice(i, i + size);
    await Promise.allSettled(batch.map(fn));
    // Small pause between batches
    if (i + size < items.length) {
      await new Promise((r) => setTimeout(r, FETCH_DELAY_MS));
    }
  }
}

export async function runWarmCache() {
  console.log("[WarmCache] Starting cache warm-up...");
  const start = Date.now();
  let warmed = 0;
  let failed = 0;

  // 1 — Station catalog (local, always fast)
  try {
    await warmStationCatalog();
    warmed++;
    console.log("[WarmCache] Station catalog ready.");
  } catch (err) {
    console.warn("[WarmCache] Catalog failed:", err.message);
    failed++;
  }

  // 2 — Popular live trains in batches
  await runInBatches(POPULAR_TRAINS, BATCH_SIZE, async (trainNo) => {
    try {
      await warmLiveTrain(trainNo);
      warmed++;
      console.log(`[WarmCache] Train ${trainNo} cached.`);
    } catch (err) {
      failed++;
      // Log a clean message — don't crash
      const reason = err.code === "ECONNABORTED" ? "timeout" : err.message;
      console.warn(`[WarmCache] Train ${trainNo} skipped: ${reason}`);
    }
  });

  // 3 — Station board stubs (lightweight, no external call)
  for (const code of POPULAR_STATIONS) {
    try {
      const timeBucket = Math.floor(Date.now() / 60000);
      const key = cacheKey("board", code, timeBucket, "en");
      await cacheGetOrSet(key, TTL.STATION_BOARD, async () => ({
        success: true,
        stationCode: code,
        warmed: true,
      }));
      warmed++;
    } catch (err) {
      console.warn(`[WarmCache] Board ${code} failed:`, err.message);
      failed++;
    }
  }

  const elapsed = ((Date.now() - start) / 1000).toFixed(1);
  console.log(
    `[WarmCache] Done — ${warmed} cached, ${failed} skipped in ${elapsed}s`
  );
}
