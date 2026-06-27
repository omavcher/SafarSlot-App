import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const stationsDataPath = path.join(__dirname, "data/stations.json");
const rawData = JSON.parse(fs.readFileSync(stationsDataPath, "utf8"));

const targetCodes = ['NDLS', 'CSMT', 'HWH', 'SBC', 'MAS', 'NGP', 'BPL', 'PUNE', 'LKO', 'INDB', 'HYB', 'CSTM', 'BCT'];
const results = {};

rawData.forEach(station => {
  const code = (station['properties/code'] || station.properties?.code || "").toUpperCase();
  if (targetCodes.includes(code)) {
    results[code] = {
      name: station['properties/name'] || station.properties?.name || "",
      hi: station.properties_name_hi || "",
      ma: station.properties_name_ma || "",
      ta: station.properties_name_ta || "",
      te: station.properties_name_te || "",
      kn: station.properties_name_kn || "",
      ml: station.properties_name_ml || "",
      bn: station.properties_name_bn || "",
      pa: station.properties_name_pa || "",
      or: station.properties_name_or || ""
    };
  }
});

console.log(JSON.stringify(results, null, 2));
