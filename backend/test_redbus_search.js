import axios from 'axios';
async function testSearch() {
  try {
    const payload = {
      src: "KYN",
      dst: "NDLS",
      doj: "20260626",
      filter: {},
      sort: {},
      allowedQuotaList: [],
      enableRecaptcha: false,
      showConnectingTrains: true
    };
    const response = await axios.post("https://www.redbus.in/rails/api/searchResults", payload, {
      headers: {
        "Content-Type": "application/json",
        "accept": "application/json, text/plain, */*",
        "accept-language": "en-US,en;q=0.9",
        "referer": "https://www.redbus.in/ryde/trains",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
      }
    });
    console.log("Search Success, trains count:", response.data.trainBtwnStnsList ? response.data.trainBtwnStnsList.length : 0);
  } catch (e) {
    console.error("Search Error:", e.message);
  }
}
testSearch();
