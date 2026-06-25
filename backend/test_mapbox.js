import axios from "axios";
import dotenv from "dotenv";
dotenv.config();

const lat = 21.1458;
const long = 79.0882;

axios.get(`https://api.mapbox.com/search/geocode/v6/reverse?longitude=${long}&latitude=${lat}&access_token=${process.env.MAP_BOX_TOKEN}`)
.then(res => {
    const cityFeature = res.data.features.find(f => f.properties?.feature_type === "place");
    if(cityFeature) {
        console.log(JSON.stringify(cityFeature.properties, null, 2));
    } else {
        console.log("No place found", JSON.stringify(res.data, null, 2));
    }
})
.catch(err => console.error(err.response?.data || err.message));
