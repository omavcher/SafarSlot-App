import axios from 'axios';

async function testPNR() {
    const pnr = "2134567890"; // Dummy PNR
    const URL = `https://cttrainsapi.confirmtkt.com/api/v2/ctpro/mweb/${pnr}?querysource=ct-mweb&locale=en&getHighChanceText=true&livePnr=false`;
    
    console.log("Testing POST...");
    try {
        const response = await axios.post(URL, { proPlanName: "" });
        console.log("POST worked!", response.data);
    } catch (e) {
        console.log("POST error:", e.response ? e.response.status : e.message);
        if (e.response && e.response.data) {
            console.log("POST error data:", e.response.data);
        }
    }
}

testPNR();
