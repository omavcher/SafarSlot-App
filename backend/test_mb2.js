import axios from 'axios';
import dotenv from 'dotenv';
dotenv.config();

async function run() {
  try {
    const lat = 21.195811;
    const long = 79.102530;
    const mbURL = https://api.mapbox.com/search/searchbox/v1/category/train_station?proximity=\,\&access_token=\;
    const res = await axios.get(mbURL);
    console.log("Features count:", res.data.features.length);
    console.log(JSON.stringify(res.data.features.map(f => f.properties.name), null, 2));
  } catch(e) {
    console.error(e.response ? e.response.data : e.message);
  }
}
run();
