import axios from 'axios';
async function run() {
  try {
    const lat = 21.195811;
    const long = 79.102530;
    const res = await axios.post('http://localhost:8080/user/get-nearby-stations', { lat, long });
    console.log(JSON.stringify(res.data, null, 2));
  } catch(e) {
    console.error(e.message);
  }
}
run();
