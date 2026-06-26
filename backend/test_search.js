import axios from 'axios';
async function run() {
  try {
    const payload = {
      src: "KYN",
      dst: "NDLS",
      doj: "20260628" // some future date
    };
    const res = await axios.post('http://localhost:8080/api/v1/train/search-between-stations', payload);
    console.log("Response Keys:", Object.keys(res.data));
    console.log("Success:", res.data.success);
    if (res.data.data && res.data.data.trainBtwnStnsList) {
      console.log("Trains Count:", res.data.data.trainBtwnStnsList.length);
      if (res.data.data.trainBtwnStnsList.length > 0) {
        console.log("First Train Object:", JSON.stringify(res.data.data.trainBtwnStnsList[0], null, 2));
      }
    } else {
      console.log("Full data:", JSON.stringify(res.data, null, 2));
    }
  } catch(e) {
    console.error("Error:", e.message, e.response?.data);
  }
}
run();
