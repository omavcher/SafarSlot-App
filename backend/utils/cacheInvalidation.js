import { cacheDelete, cacheDeletePattern, cacheKey, CACHE_VERSION } from "./cache.js";

/** Invalidate live train, coach, and optional station board caches after a report/update. */
export async function invalidateTrainCaches(trainNo, stationCode) {
  if (!trainNo) return;

  const normalizedTrain = String(trainNo).trim();
  const patterns = [
    `${CACHE_VERSION}_live_${normalizedTrain}*`,
    `${CACHE_VERSION}_coach_${normalizedTrain}*`,
  ];

  if (stationCode) {
    const code = String(stationCode).trim().toUpperCase();
    patterns.push(`${CACHE_VERSION}_board_${code}*`);
  }

  await Promise.all(patterns.map((p) => cacheDeletePattern(p)));
}

export async function invalidateStationCaches(stationId, stationCode) {
  if (stationId) {
    await cacheDeletePattern(`${CACHE_VERSION}_station_${stationId}*`);
  }
  if (stationCode) {
    const code = String(stationCode).trim().toUpperCase();
    await cacheDeletePattern(`${CACHE_VERSION}_board_${code}*`);
    await cacheDeletePattern(`${CACHE_VERSION}_station_detail_${code}*`);
  }
}

export async function invalidatePnrCache(pnr) {
  if (!pnr) return;
  await cacheDeletePattern(`${CACHE_VERSION}_pnr_${pnr}*`);
}
