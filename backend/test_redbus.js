import axios from 'axios';
async function run() {
  try {
    const response = await axios.post("https://www.redbus.in/rails/api/getPnrToolKitData", {
      mobile: "",
      pnr: "6305523373"
    }, {
      headers: {
        "Content-Type": "application/json",
        "accept": "application/json, text/plain, */*",
        "accept-language": "en-US,en;q=0.9",
        "referer": "https://www.redbus.in/ryde/pnr",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
      }
    });
    console.log("Response:", response.data);
  } catch(e) {
    console.error("Error:", e.message);
    if (e.response) {
      console.error("Error response:", e.response.status, e.response.data);
    }
  }
}
run();
