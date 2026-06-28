import { WebSocketServer } from "ws";
import axios from "axios";
import { cacheGetOrSet, cacheKey, TTL } from "../utils/cache.js";
import { enrichLiveTrainStatus } from "../utils/localization.js";

const REDBUS_HEADERS = {
  accept: "application/json, text/plain, */*",
  "User-Agent":
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
};

async function fetchLiveTrainData(trainNo, lang = "en") {
  const key = cacheKey("live", trainNo, lang);
  return cacheGetOrSet(
    key,
    TTL.LIVE_TRAIN,
    async () => {
      const URL = `https://www.redbus.in/railways/api/getLtsDetails?trainNo=${trainNo}`;
      const response = await axios.get(URL, { headers: REDBUS_HEADERS, timeout: 10000 });
      const resData = response.data;
      enrichLiveTrainStatus(resData, lang);
      return { success: true, resData, _cachedAt: Date.now() };
    },
    { shouldCache: (body) => body?.success === true }
  );
}

/** Minimal delta: only changed fields vs last push. */
function buildDelta(prev, next) {
  if (!prev || !next?.resData) return next;

  const prevData = prev.resData || {};
  const nextData = next.resData || {};
  const delta = { success: true, trainNo: nextData.trainNumber, _delta: true };

  if (prevData.currentStationCode !== nextData.currentStationCode) {
    delta.currentStationCode = nextData.currentStationCode;
  }
  if (prevData.currentDelay !== nextData.currentDelay) {
    delta.currentDelay = nextData.currentDelay;
  }
  if (JSON.stringify(prevData.stations?.slice(0, 3)) !== JSON.stringify(nextData.stations?.slice(0, 3))) {
    delta.stations = nextData.stations;
  }

  const keys = Object.keys(delta).filter((k) => !k.startsWith("_"));
  return keys.length > 2 ? next : delta;
}

export function attachLiveTrainSocket(server) {
  const wss = new WebSocketServer({ server, path: "/ws/live-train" });

  wss.on("connection", (ws, req) => {
    const url = new URL(req.url, "http://localhost");
    const trainNo = url.searchParams.get("trainNo");
    const lang = url.searchParams.get("lang") || "en";

    if (!trainNo) {
      ws.send(JSON.stringify({ error: "trainNo required" }));
      ws.close();
      return;
    }

    let lastPayload = null;
    let active = true;

    const pushUpdate = async () => {
      if (!active || ws.readyState !== ws.OPEN) return;
      try {
        const fresh = await fetchLiveTrainData(trainNo, lang);
        const payload = buildDelta(lastPayload, fresh);
        lastPayload = fresh;
        ws.send(JSON.stringify(payload));
      } catch (err) {
        ws.send(JSON.stringify({ error: err.message }));
      }
    };

    pushUpdate();
    const interval = setInterval(pushUpdate, TTL.LIVE_TRAIN * 1000);

    ws.on("close", () => {
      active = false;
      clearInterval(interval);
    });

    ws.on("error", () => {
      active = false;
      clearInterval(interval);
    });
  });

  console.log("WebSocket live-train server ready at /ws/live-train");
}
