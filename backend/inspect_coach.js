import axios from 'axios';
async function run() {
  try {
    const URL = `https://www.redbus.in/railways/api/getCoachPosition?trainNo=12626&stn=NDLS`;
    const response = await axios.get(URL);
    console.log("CoachPosition response keys:", Object.keys(response.data));
    console.log("source:", response.data.source);
    console.log("destination:", response.data.destination);
    console.log("queriedStation:", response.data.queriedStation);
    if (response.data.listOfStations) {
      console.log("listOfStations length:", response.data.listOfStations.length);
      console.log("Sample station from listOfStations:", JSON.stringify(response.data.listOfStations[0], null, 2));
    }
  } catch(e) {
    console.error("Error:", e.message);
  }
}
run();
