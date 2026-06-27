import axios from 'axios';

async function testDDGImages() {
  try {
    const query = 'Anjani Railway Station ANO';
    const mainUrl = `https://duckduckgo.com/?q=${encodeURIComponent(query)}`;
    
    const mainResponse = await axios.get(mainUrl, {
      headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
      }
    });

    const html = mainResponse.data;
    const vqdMatch = /vqd=['"]?([^'"]+)['"]?/.exec(html) || /vqd\s*[:=]\s*['"]?([^'"]+)['"]?/.exec(html);
    if (!vqdMatch) {
      console.error("VQD not found in HTML");
      return;
    }
    const vqd = vqdMatch[1];
    console.log("VQD found:", vqd);

    // Filter using size:Large, layout:Wide
    const imagesUrl = `https://duckduckgo.com/i.js?q=${encodeURIComponent(query)}&o=json&vqd=${vqd}&f=size:Large,layout:Wide`;
    
    console.log("Fetching images from:", imagesUrl);
    const imagesResponse = await axios.get(imagesUrl, {
      headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
        "Referer": mainUrl
      }
    });

    const data = imagesResponse.data;
    console.log("Response keys:", Object.keys(data));
    const results = data.results || [];
    console.log("Results count:", results.length);
    for (let i = 0; i < Math.min(results.length, 5); i++) {
      console.log(`\nResult ${i}:`);
      console.log(JSON.stringify(results[i], null, 2));
    }
  } catch (error) {
    console.error("Error:", error.message);
  }
}

testDDGImages();
