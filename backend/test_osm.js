import axios from 'axios';
async function run() {
  try {
    const lat = 21.079997;
    const long = 79.122932;
    const radius = 20000;
    const query = [out:json];node(around:\,\,\)["railway"="station"];out;;

    const response = await axios.post(
      'https://overpass-api.de/api/interpreter',
      data=\,
      { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
    );
    console.log("Success! Count:", response.data.elements.length);
  } catch(e) {
    console.error("Error:", e.message);
    if(e.response) {
      console.error("Status:", e.response.status);
      console.error("Headers:", e.response.headers);
      console.error("Data:", e.response.data);
    }
  }
}
run();
