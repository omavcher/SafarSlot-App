import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const STATION_LANG_KEYS = ["en", "hi", "ma", "ta", "tel", "ka", "mal", "bengali", "panj", "odia"];
const TRAIN_LANG_KEYS = ["en", "hi", "ma", "ta", "tel", "ka", "mal", "bengali", "panj", "odia"];

export const CODE_ALIASES = {
  CSMT: "CSTM",
  MMCT: "BCT",
};

const normalizeStations = (data) => {
  const features = Array.isArray(data) ? data : (data.features || []);
  return features.map((station) => {
    if (station.properties && station.properties.code) {
      return station;
    }

    const code = station["properties/code"] || "";
    const name = station["properties/name"] || "";
    const zone = station["properties/zone"] || "";
    const state = station["properties/state"] || "";
    const address = station["properties/address"] || "";

    let coordinates = null;
    if (
      station["geometry/coordinates/0"] !== undefined &&
      station["geometry/coordinates/1"] !== undefined
    ) {
      const lng = parseFloat(station["geometry/coordinates/0"] || 0);
      const lat = parseFloat(station["geometry/coordinates/1"] || 0);
      coordinates = [lng, lat];
    } else if (station.geometry && station.geometry.coordinates) {
      coordinates = station.geometry.coordinates;
    }

    return {
      ...station,
      properties: { code, name, zone, state, address },
      geometry: {
        type: station["geometry/type"] || "Point",
        coordinates: coordinates || [0, 0],
      },
    };
  });
};

const stationsDataPath = path.join(__dirname, "../data/stations.json");
const trainsDataPath = path.join(__dirname, "../data/trains.json");

const rawStations = JSON.parse(fs.readFileSync(stationsDataPath, "utf8"));
export const localStations = normalizeStations(rawStations);

export const stationsMap = {};
export const stationsObjMap = {};

localStations.forEach((station) => {
  if (station.properties && station.properties.code) {
    const codeUpper = station.properties.code.toUpperCase();
    stationsObjMap[codeUpper] = station;
    if (station.geometry && station.geometry.coordinates) {
      stationsMap[codeUpper] = station.geometry.coordinates;
    }
  }
});

export const trainsMap = {};
try {
  const rawTrains = JSON.parse(fs.readFileSync(trainsDataPath, "utf8"));
  rawTrains.forEach((train) => {
    if (train.code != null) {
      trainsMap[String(train.code)] = train;
    }
  });
} catch (error) {
  console.error("Error loading trains.json:", error.message);
}

const cleanLangCode = (lang) => {
  if (!lang) return "en";
  return lang.split("-")[0].toLowerCase();
};

const isUsableName = (value, code) => {
  if (!value) return false;
  const trimmed = String(value).trim();
  if (!trimmed) return false;
  if (code && trimmed.toUpperCase() === String(code).toUpperCase()) return false;
  return true;
};

const resolveStationRecord = (code) => {
  if (!code) return null;
  const cleanCode = String(code).trim().toUpperCase();
  const normalized = CODE_ALIASES[cleanCode] || cleanCode;
  return stationsObjMap[normalized] || stationsObjMap[cleanCode] || null;
};

export const getStationNamesByCode = (code) => {
  const station = resolveStationRecord(code);
  if (!station) return null;

  const englishName = station.properties?.name || "";
  const names = {
    en: englishName,
    hi: station.properties_name_hi || englishName,
    ma: station.properties_name_ma || englishName,
    ta: station.properties_name_ta || englishName,
    tel: station.properties_name_te || englishName,
    ka: station.properties_name_kn || englishName,
    mal: station.properties_name_ml || englishName,
    bengali: station.properties_name_bn || englishName,
    panj: station.properties_name_pa || englishName,
    odia: station.properties_name_or || englishName,
  };

  const cleanCode = String(code).trim().toUpperCase();
  STATION_LANG_KEYS.forEach((key) => {
    if (!isUsableName(names[key], cleanCode)) {
      names[key] = englishName || names.en || "";
    }
  });

  return names;
};

export const getTrainNamesByNumber = (trainNo) => {
  if (trainNo == null || trainNo === "") return null;

  const cleanNo = String(trainNo).trim().replace(/\D/g, "");
  if (!cleanNo) return null;

  const train = trainsMap[cleanNo];
  if (!train) return null;

  const englishName = train.train_name_en || "";
  const names = {
    en: englishName,
    hi: train.train_name_hi || englishName,
    ma: train.train_name_mr || englishName,
    ta: train.train_name_ta || englishName,
    tel: train.train_name_te || englishName,
    ka: train.train_name_kn || englishName,
    mal: train.train_name_ml || englishName,
    bengali: train.train_name_bn || englishName,
    panj: train.train_name_pa || englishName,
    odia: train.train_name_or || englishName,
  };

  TRAIN_LANG_KEYS.forEach((key) => {
    if (!names[key] || !String(names[key]).trim()) {
      names[key] = englishName || names.en || "";
    }
  });

  return names;
};

export const pickLocalizedName = (names, lang) => {
  if (!names) return "";
  const cleanLang = cleanLangCode(lang);
  const aliases = {
    te: "tel",
    kn: "ka",
    ml: "mal",
    bn: "bengali",
    pa: "panj",
    or: "odia",
    mr: "ma",
    bengali: "bengali",
    panj: "panj",
    odia: "odia",
    mal: "mal",
    tel: "tel",
    ka: "ka",
  };
  const key = aliases[cleanLang] || cleanLang;
  if (names[key] && String(names[key]).trim()) return names[key];
  if (names.en && String(names.en).trim()) return names.en;
  return Object.values(names).find((value) => value && String(value).trim()) || "";
};

export const getLocalizedStationName = (station, lang) => {
  if (!station) return "Unknown Station";
  const code = station.properties?.code;
  const names = getStationNamesByCode(code);
  if (!names) return station.properties?.name || "Unknown Station";
  return pickLocalizedName(names, lang) || station.properties?.name || "Unknown Station";
};

export const getLocalizedNameByCode = (code, lang) => {
  const names = getStationNamesByCode(code);
  if (!names) return "";
  return pickLocalizedName(names, lang);
};

export const applyStationNames = (obj, code, nameFields = [], lang = null) => {
  if (!obj || !code) return obj;
  const names = getStationNamesByCode(code);
  if (!names) return obj;

  obj.stationNames = names;
  const displayName = pickLocalizedName(names, lang);
  nameFields.forEach((field) => {
    if (field in obj) obj[field] = displayName;
  });
  return obj;
};

export const applyTrainNames = (obj, trainNo, nameFields = [], lang = null) => {
  if (!obj || trainNo == null || trainNo === "") return obj;
  const names = getTrainNamesByNumber(trainNo);
  if (!names) return obj;

  obj.trainNames = names;
  const displayName = pickLocalizedName(names, lang);
  nameFields.forEach((field) => {
    if (field in obj) obj[field] = displayName;
  });
  return obj;
};

export const enrichPnrData = (pnrData, lang) => {
  if (!pnrData) return pnrData;

  if (pnrData.trainNumber != null) {
    applyTrainNames(pnrData, pnrData.trainNumber, ["trainName"], lang);
  }
  if (pnrData.srcCode) {
    const names = getStationNamesByCode(pnrData.srcCode);
    if (names) {
      pnrData.srcNames = names;
      pnrData.srcName = pickLocalizedName(names, lang);
    }
  }
  if (pnrData.dstCode) {
    const names = getStationNamesByCode(pnrData.dstCode);
    if (names) {
      pnrData.dstNames = names;
      pnrData.dstName = pickLocalizedName(names, lang);
    }
  }
  if (pnrData.boardingStationData?.stnCode) {
    const names = getStationNamesByCode(pnrData.boardingStationData.stnCode);
    if (names) {
      pnrData.boardingStationData.stationNames = names;
      pnrData.boardingStationData.stnName = pickLocalizedName(names, lang);
    }
  }
  if (pnrData.bookReturn) {
    if (pnrData.bookReturn.srcCode) {
      const names = getStationNamesByCode(pnrData.bookReturn.srcCode);
      if (names) {
        pnrData.bookReturn.srcNames = names;
        pnrData.bookReturn.srcName = pickLocalizedName(names, lang);
      }
    }
    if (pnrData.bookReturn.dstCode) {
      const names = getStationNamesByCode(pnrData.bookReturn.dstCode);
      if (names) {
        pnrData.bookReturn.dstNames = names;
        pnrData.bookReturn.dstName = pickLocalizedName(names, lang);
      }
    }
  }

  return pnrData;
};

export const enrichLiveTrainStatus = (resData, lang) => {
  if (!resData) return resData;

  if (resData.trainNumber != null) {
    applyTrainNames(resData, resData.trainNumber, ["trainName"], lang);
  }

  if (Array.isArray(resData.stations)) {
    resData.stations = resData.stations.map((st) => {
      const code = st.stationCode ? st.stationCode.trim().toUpperCase() : "";
      const normalized = CODE_ALIASES[code] || code;
      const coords = stationsMap[normalized] || stationsMap[code];
      if (coords) {
        st.lng = coords[0];
        st.lat = coords[1];
      }
      applyStationNames(st, code, ["stationName"], lang);
      return st;
    });
  }

  return resData;
};

export const enrichStationBoardItem = (item, lang) => {
  if (!item) return item;

  if (item.station_code || item.stationCode) {
    applyStationNames(
      item,
      item.station_code || item.stationCode,
      ["station_name", "stationName"],
      lang
    );
  }

  if (item.train_number || item.trainNumber) {
    applyTrainNames(
      item,
      item.train_number || item.trainNumber,
      ["train_name", "trainName"],
      lang
    );
  }

  return item;
};
