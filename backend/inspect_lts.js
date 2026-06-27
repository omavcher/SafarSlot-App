import axios from 'axios';
async function run() {
  try {
    const response = await axios.get("https://www.redbus.in/railways/api/getLtsDetails?trainNo=12626");
    const data = response.data;
    // Look at top-level keys and sample data
    console.log("Top-level keys:", Object.keys(data));
    console.log("Sample station:", data.stations ? data.stations[0] : null);
    // Print any other keys that might have station codes or names
    for (const key of Object.keys(data)) {
      if (typeof data[key] === 'string' && (data[key].includes('Junction') || data[key].includes('Terminus') || /^[A-Z]{3,4}$/.test(data[key]))) {
        console.log(`Key "${key}": "${data[key]}"`);
      }
    }
  } catch(e) {
    console.error("Error:", e.message);
  }
}
run();
