import axios from 'axios';
async function run() {
  try {
    const URL = `https://www.redbus.in/railways/api/SolrTrainSearch?search=12626`;
    const response = await axios.get(URL);
    console.log("SolrTrainSearch response docs keys:", response.data.response.docs ? Object.keys(response.data.response.docs[0]) : 'None');
    if (response.data.response.docs && response.data.response.docs.length > 0) {
      console.log("First doc:", JSON.stringify(response.data.response.docs[0], null, 2));
    }
  } catch(e) {
    console.error("Error:", e.message);
  }
}
run();
