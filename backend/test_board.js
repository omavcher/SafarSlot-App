import axios from 'axios';
async function run() {
  try {
    console.log("Querying Nagpur Junction (NGP) Station Board at simulated time 14:18...");
    // Passing simulated time 14:18 for reproducibility (matching user prompt example)
    const res = await axios.get('http://localhost:8080/api/v1/train/station-board/NGP?time=14:18');
    
    console.log("Response Keys:", Object.keys(res.data));
    console.log("Current Time:", res.data.currentTime);
    console.log("Arriving Soon Count:", res.data.arrivingSoon.length);
    console.log("At Platform Count:", res.data.atPlatform.length);
    console.log("Departed Recently Count:", res.data.departedRecently.length);
    console.log("Next Trains Count:", res.data.nextTrains.length);
    
    console.log("\n--- Arriving Soon Sample ---");
    if (res.data.arrivingSoon.length > 0) {
      console.log(res.data.arrivingSoon.slice(0, 2));
    }
    
    console.log("\n--- At Platform Sample ---");
    if (res.data.atPlatform.length > 0) {
      console.log(res.data.atPlatform.slice(0, 2));
    }

    console.log("\n--- Statistics ---");
    console.log(res.data.stats);

  } catch(e) {
    console.error("Error:", e.message, e.response?.data);
  }
}
run();
