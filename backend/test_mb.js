import axios from 'axios';
import dotenv from 'dotenv';
dotenv.config();
async function run() {
  try {
    const lat = 21.195811;
    const long = 79.102530;
    const URL = `https://api.mapbox.com/search/searchbox/v1/category/train_station?proximity=${long},${lat}&access_token=${process.env.MAP_BOX_TOKEN}`;
    const res = await axios.get(URL);
    console.log(res.data.features.map(f => `${f.properties.name} - ${f.properties.maki} - ${f.properties.poi_category.join(',')}`));
  } catch(e) {
    console.error(e.message);
  }
}
run();
