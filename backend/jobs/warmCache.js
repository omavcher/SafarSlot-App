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

async function warmLiveTrain(trainNo) {
  const key = cacheKey("live", trainNo, "en");
  await cacheGetOrSet(
    key,
    TTL.LIVE_TRAIN,
    async () => {
      const URL = `https://www.redbus.in/railways/api/getLtsDetails?trainNo=${trainNo}`;
      const response = await axios.get(URL, { headers: REDBUS_HEADERS, timeout: 10000 });
      return { success: true, resData: response.data };
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

export async function runWarmCache() {
  console.log("[WarmCache] Starting cache warm-up...");
  const start = Date.now();
  let warmed = 0;

  try {
    await warmStationCatalog();
    warmed++;
  } catch (err) {
    console.warn("[WarmCache] Catalog failed:", err.message);
  }

  for (const trainNo of POPULAR_TRAINS) {
    try {
      await warmLiveTrain(trainNo);
      warmed++;
    } catch (err) {
      console.warn(`[WarmCache] Train ${trainNo} failed:`, err.message);
    }
    await new Promise((r) => setTimeout(r, 200));
  }

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
    }
  }

  console.log(`[WarmCache] Done — ${warmed} items in ${Date.now() - start}ms`);
}
