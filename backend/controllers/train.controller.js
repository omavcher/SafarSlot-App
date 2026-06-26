import axios from "axios";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { TrainReport } from "../models/report.model.js";
import jwt from "jsonwebtoken";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);


const stationsDataPath = path.join(__dirname, "../data/stations.json");
const localStationsData = JSON.parse(fs.readFileSync(stationsDataPath, "utf8"));
const localStations = localStationsData.features;

const stationsMap = {};
localStations.forEach((station) => {
  if (station.properties && station.properties.code && station.geometry && station.geometry.coordinates) {
    stationsMap[station.properties.code] = station.geometry.coordinates; // [lng, lat]
  }
});

export const getPNR = async (req, res) => {
    try {
        const pnr = req.query.pnr || req.body.pnr;
        if (!pnr || pnr.toString().length !== 10) {
            return res.status(400).json({
                success: false,
                message: "Please Provide Correct 10-Digit PNR",
            });
        }
        
        const URL = "https://www.redbus.in/rails/api/getPnrToolKitData";
        const response = await axios.post(URL, {
            mobile: "",
            pnr: pnr.toString()
        }, {
            headers: {
                "Content-Type": "application/json",
                "accept": "application/json, text/plain, */*",
                "accept-language": "en-US,en;q=0.9",
                "referer": "https://www.redbus.in/ryde/pnr",
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
            }
        });
        
        const pnrData = response.data;
        
        // If there's an error message or errorcode in response
        if (pnrData.errorcode && pnrData.errorcode !== "0") {
            return res.status(200).json({
                success: false,
                message: pnrData.errormsg || pnrData.detailedmsg || "PNR Number doesn't exist",
                data: pnrData
            });
        }
        
        res.status(200).json({
            success: true,
            message: "PNR Status Fetched Successfully",
            data: pnrData
        });
    } catch (error) {
        console.error("Get PNR Error", error.message);
        res.status(500).json({ success: false, message: error.message });
    }
}

export const stationsList = async (req,res)=>{
  try{
       const search = req.params.search;
       if (!search) {
         return res.status(400).json({ success: false, message: "Search query is required" });
       }
       const URL = `https://www.redbus.in/rails/api/solarSearch?search=${search}`;
       const response = await axios.get(URL);
       const resData = response.data.response;
       res.status(200).json({success:true,resData});
  }catch(err){
    const apiError = err.response?.data || err.message;
    console.error("Station List Error", apiError);
    const statusCode = err.response?.status || 500;
    const message = err.response?.data?.error?.message || err.message || "Station service error";
    res.status(statusCode === 500 ? 502 : statusCode).json({success:false,message});
  }
}

export const getTrainNameCode = async (req,res)=>{
    try{
          const search = req.params.search;
       if (!search) {
         return res.status(400).json({ success: false, message: "Search query is required" });
       }
        const URL = `https://www.redbus.in/railways/api/SolrTrainSearch?search=${search}`

        const response = await axios.get(URL);
        const resData = response.data.response;
        res.status(200).json({success:true,resData});

    }catch(err){
        res.status(500).json({success:false,message:err.message})
    }
}



export const liveTrainStatus = async (req,res)=>{
   try {
    const {trainNo} = req.params;
    if (!trainNo) {
         return res.status(400).json({ success: false, message: "trainNo  is required" });
       }

    const URL = `https://www.redbus.in/railways/api/getLtsDetails?trainNo=${trainNo}`;
    const response = await axios.get(URL);
    const resData = response.data;
    
    if (resData && resData.stations) {
      resData.stations = resData.stations.map(st => {
        const code = st.stationCode ? st.stationCode.trim().toUpperCase() : "";
        const coords = stationsMap[code];
        if (coords) {
          st.lng = coords[0];
          st.lat = coords[1];
        }
        return st;
      });
    }

    res.status(200).json({success:true,resData});
   } catch (error) {
            res.status(500).json({success:false,message:error.message})
   }
}



// export const CreateSavedRoutes

// export const getSavedRoutes


export const CoachPosition = async (req, res) => {
    try {
      const trainNo = req.query.trainNo || req.body.trainNo;
      const station = req.query.stn || req.body.station || 'null';
      if (!trainNo) {
        return res.status(400).json({ success: false, message: 'trainNo is required' });
      }
      const URL = `https://www.redbus.in/railways/api/getCoachPosition?trainNo=${trainNo}&stn=${station}`;
      const response = await axios.get(URL);
      const resData = response.data;
      res.status(200).json({ success: true, resData });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
};

export const reportTrain = async (req, res) => {
  try {
    let userId = null;
    const authHeader = req.headers['authorization'];
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      try {
        const decodedToken = jwt.verify(token, process.env.JWT_SECRET);
        userId = decodedToken.userId;
      } catch (e) {} // ignore if token is invalid or expired for guest
    }

    const { trainNo, trainName, category, message } = req.body;

    if (!trainNo || !trainName || !category) {
      return res.status(400).json({ success: false, message: "Missing required fields" });
    }

    const newReport = new TrainReport({
      userId,
      trainNo,
      trainName,
      category,
      message: message || ''
    });

    await newReport.save();

    res.status(201).json({ success: true, message: "Train report submitted successfully", data: newReport });
  } catch (error) {
    console.error("Report Train Error:", error);
    res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

let cachedBrv1Cookie = "cede4c52b4961d7275a5a7257fabf138";

const generateIrisCookie = () => {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  let iris = '';
  for (let i = 0; i < 25; i++) {
    iris += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return iris;
};

const solveBrowserVerification = async (id, irisCookie) => {
  try {
    const mapUrl = `https://d.indiarailinfo.com/station/map/${id}`;
    const mapResponse = await axios.get(mapUrl, {
      headers: {
        "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
        "accept-language": "en-US,en;q=0.5",
        "cookie": `iris=${irisCookie}`,
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
      }
    });

    const html = mapResponse.data;

    // If it's already the actual page (no verify-browser challenge)
    if (!html.includes('verify-browser')) {
      return { html, brv1: cachedBrv1Cookie };
    }

    const aMatch = /#iri-a::before\s*\{\s*content:\s*['"](\d+)['"]/i.exec(html);
    const bMatch = /#iri-b::before\s*\{\s*content:\s*['"](\d+)['"]/i.exec(html);
    const opMatch = /data-op="(\d+)"/i.exec(html);
    const sigMatch = /data-sig="([^"]+)"/i.exec(html);

    if (!aMatch || !bMatch || !opMatch || !sigMatch) {
      return { html, brv1: cachedBrv1Cookie };
    }

    const a = parseInt(aMatch[1], 10);
    const b = parseInt(bMatch[1], 10);
    const op = parseInt(opMatch[1], 10);
    const sig = sigMatch[1];

    let nonce;
    if (op === 1) { nonce = a * b; }
    else if (op === 2) { nonce = (a + b) * (a - b + 100); }
    else { nonce = (a * b) + (a + b); }
    nonce = (((nonce % 900000) + 900000) % 900000) + 100000;

    const ts = Math.floor(Date.now() / 1000);
    const token = [0, 5, 1, 1, 4, 1, 1, 0, nonce, sig, ts].join(":");

    const verifyUrl = `https://d.indiarailinfo.com/verify-browser?t=${token}`;
    const verifyResponse = await axios.get(verifyUrl, {
      headers: {
        "accept": "*/*",
        "accept-language": "en-US,en;q=0.5",
        "cookie": `iris=${irisCookie}`,
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Referer": mapUrl,
        "x-requested-with": "XMLHttpRequest"
      }
    });

    let obtainedBrv1 = cachedBrv1Cookie;
    const setCookie = verifyResponse.headers['set-cookie'];
    if (setCookie) {
      for (const cookieStr of setCookie) {
        if (cookieStr.includes('brv1=')) {
          const match = /brv1=([^;]+)/.exec(cookieStr);
          if (match) {
            obtainedBrv1 = match[1];
          }
        }
      }
    }

    cachedBrv1Cookie = obtainedBrv1;

    const finalMapResponse = await axios.get(mapUrl, {
      headers: {
        "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
        "accept-language": "en-US,en;q=0.5",
        "cookie": `brv1=${obtainedBrv1}; iris=${irisCookie}`,
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
      }
    });

    return { html: finalMapResponse.data, brv1: obtainedBrv1 };

  } catch (error) {
    console.error("Error solving challenge:", error.message);
    throw error;
  }
};

export const searchStationsIndiarailinfo = async (req, res) => {
  try {
    const search = req.params.search || req.query.search || 'n';
    const date = Date.now();
    const URL = `https://d.indiarailinfo.com/shtml/list.shtml?LappGetStationList/${encodeURIComponent(search)}/0/0/0?&date=${date}&seq=0`;

    const randomIris = generateIrisCookie();
    const { brv1 } = await solveBrowserVerification('196', randomIris);

    const response = await axios.get(URL, {
      headers: {
        "accept": "*/*",
        "accept-language": "en-US,en;q=0.5",
        "priority": "u=1, i",
        "sec-ch-ua": "\"Brave\";v=\"149\", \"Chromium\";v=\"149\", \"Not)A;Brand\";v=\"24\"",
        "sec-ch-ua-mobile": "?0",
        "sec-ch-ua-platform": "\"Windows\"",
        "sec-fetch-dest": "empty",
        "sec-fetch-mode": "cors",
        "sec-fetch-site": "same-origin",
        "sec-gpc": "1",
        "x-requested-with": "XMLHttpRequest",
        "cookie": `brv1=${brv1}; iris=${randomIris}`,
        "Referer": "https://d.indiarailinfo.com/station/map/196",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
      }
    });

    const htmlContent = response.data;

    const cleanText = (str) => {
      if (!str) return "";
      return str
        .replace(/<[^>]+>/g, '')
        .replace(/&nbsp;/g, ' ')
        .replace(/&amp;/g, '&')
        .replace(/\s+/g, ' ')
        .trim();
    };

    const trRegex = /<tr\b[^>]*>([\s\S]*?)<\/tr>/gi;
    let trMatch;
    const m1List = [];
    const m2List = {};

    while ((trMatch = trRegex.exec(htmlContent)) !== null) {
      const trContent = trMatch[0];
      
      const m1Match = /class=rowM1\s+rowNum="(\d+)"/i.exec(trContent);
      if (m1Match) {
        const rowNum = m1Match[1];
        
        const idMatch = /<td[^>]*style="[^"]*display:\s*none[^"]*"[^>]*>(\d+)<\/td>/i.exec(trContent);
        const id = idMatch ? idMatch[1] : "";
        
        const rcolMatch = /<td[^>]*class=rcol[^>]*>([\s\S]*?)<\/td>/i.exec(trContent);
        const code = rcolMatch ? cleanText(rcolMatch[1]) : "";
        
        const icolMatch = /<td[^>]*class=icol[^>]*>([\s\S]*?)<\/td>/i.exec(trContent);
        const name = icolMatch ? cleanText(icolMatch[1]) : "";
        
        const jcolMatch = /<td[^>]*class=jcol[^>]*>([\s\S]*?)<\/td>/i.exec(trContent);
        const division = jcolMatch ? cleanText(jcolMatch[1]) : "";
        
        m1List.push({ rowNum, id, code, name, division });
        continue;
      }

      const m2Match = /class=rowm2\s+rowNum="(\d+)"/i.exec(trContent);
      if (m2Match) {
        const rowNum = m2Match[1];
        
        const detailsMatch = /<td[^>]*colspan=2[^>]*>([\s\S]*?)<\/td>/i.exec(trContent);
        const details = detailsMatch ? cleanText(detailsMatch[1]) : "";
        
        m2List[rowNum] = details;
      }
    }

    const parsedStations = m1List.map(item => ({
      id: item.id,
      code: item.code,
      name: item.name,
      division: item.division,
      details: m2List[item.rowNum] || ""
    }));

    res.status(200).json({
      success: true,
      stations: parsedStations
    });

  } catch (error) {
    console.error("Indiarailinfo Search Error:", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

const searchStationImages = async (query) => {
  try {
    const mainUrl = `https://duckduckgo.com/?q=${encodeURIComponent(query)}`;
    const mainResponse = await axios.get(mainUrl, {
      headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
      },
      timeout: 5000
    });

    const html = mainResponse.data;
    const vqdMatch = /vqd=['"]?([^'"]+)['"]?/.exec(html) || /vqd\s*[:=]\s*['"]?([^'"]+)['"]?/.exec(html);
    if (!vqdMatch) {
      console.warn("VQD not found in HTML for query:", query);
      return [];
    }
    const vqd = vqdMatch[1];

    const imagesUrl = `https://duckduckgo.com/i.js?q=${encodeURIComponent(query)}&o=json&vqd=${vqd}&f=size:Large,layout:Wide`;
    const imagesResponse = await axios.get(imagesUrl, {
      headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
        "Referer": mainUrl
      },
      timeout: 5000
    });

    const results = imagesResponse.data.results || [];
    const filteredImages = [];

    for (const item of results) {
      if (!item.image) continue;

      const width = parseInt(item.width, 10) || 0;
      const height = parseInt(item.height, 10) || 0;
      
      if (width >= 800 && height > 0 && (width / height) >= 1.3) {
        filteredImages.push({
          url: item.image,
          caption: item.title || "Station Image"
        });
      }
    }

    return filteredImages;
  } catch (error) {
    console.error("Error fetching images from DDG:", error.message);
    return [];
  }
};

export const getStationDetailsIndiarailinfo = async (req, res) => {
  try {
    const id = req.params.id || req.query.id;
    if (!id) {
      return res.status(400).json({ success: false, message: "Station ID is required" });
    }

    const randomIris = generateIrisCookie();
    const irisKey = randomIris.substring(0, 16);

    // 1. Fetch map page dynamically, automatically bypasses verify-browser anti-bot
    const { html, brv1 } = await solveBrowserVerification(id, randomIris);

    // 2. Parse title and meta description
    const titleMatch = /<title>([\s\S]*?)<\/title>/i.exec(html);
    const title = titleMatch ? titleMatch[1].trim() : "";

    const descMatch = /<meta name="description" content="([\s\S]*?)"/i.exec(html);
    const description = descMatch ? descMatch[1].trim() : "";

    // 3. Fetch sinfo details
    const sinfoUrl = `https://d.indiarailinfo.com/sinfo?s=${id}&kkk=${Date.now()}`;
    const sinfoResponse = await axios.get(sinfoUrl, {
      headers: {
        "accept": "application/json, text/javascript, */*; q=0.01",
        "accept-language": "en-US,en;q=0.5",
        "cookie": `brv1=${brv1}; iris=${randomIris}`,
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Referer": `https://d.indiarailinfo.com/station/map/${id}`,
        "x-requested-with": "XMLHttpRequest"
      }
    });

    const sinfo = sinfoResponse.data;

    // Decrypt coordinates using XXTEA algorithm (pl1fgh)
    const Base64 = {
      decode: function(input) {
        return Buffer.from(input, 'base64').toString('binary');
      }
    };

    const Utf8 = {
      encode: function(input) {
        return Buffer.from(input, 'utf8').toString('binary');
      },
      decode: function(input) {
        return Buffer.from(input, 'binary').toString('utf8');
      }
    };

    const prs1ql = {
      strToLongs: function(a) {
        const b = Array(Math.ceil(a.length / 4));
        for (let c = 0; c < b.length; c++) {
          b[c] = (a.charCodeAt(4 * c) || 0) +
                 ((a.charCodeAt(4 * c + 1) || 0) << 8) +
                 ((a.charCodeAt(4 * c + 2) || 0) << 16) +
                 ((a.charCodeAt(4 * c + 3) || 0) << 24);
        }
        return b;
      },
      longsToStr: function(a) {
        const b = Array(a.length);
        for (let c = 0; c < a.length; c++) {
          b[c] = String.fromCharCode(
            a[c] & 255,
            (a[c] >>> 8) & 255,
            (a[c] >>> 16) & 255,
            (a[c] >>> 24) & 255
          );
        }
        return b.join("");
      },
      pl1fgh: function(a, b) {
        if (a.length === 0) return "";
        a = prs1ql.strToLongs(Base64.decode(a));
        b = prs1ql.strToLongs(Utf8.encode(b).slice(0, 16));
        let c = a.length;
        let d;
        let f = a[0];
        let e;
        let g = 2654435769 * Math.floor(6 + 52 / c);
        while (g !== 0) {
          e = (g >>> 2) & 3;
          for (let k = c - 1; 0 <= k; k--) {
            d = a[0 < k ? k - 1 : c - 1];
            d = ((d >>> 5 ^ f << 2) + (f >>> 3 ^ d << 4)) ^ ((g ^ f) + (b[(k & 3) ^ e] ^ d));
            a[k] = (a[k] - d) | 0;
            f = a[k];
          }
          g = (g - 2654435769) | 0;
        }
        a = prs1ql.longsToStr(a);
        a = a.replace(/\0+$/, "");
        return Utf8.decode(a);
      }
    };

    let latitude = "";
    let longitude = "";
    if (sinfo.Lat && sinfo.Lng) {
      latitude = prs1ql.pl1fgh(sinfo.Lat, irisKey);
      longitude = prs1ql.pl1fgh(sinfo.Lng, irisKey);
    }

    const cleanText = (str) => {
      if (!str) return "";
      return str.replace(/<[^>]+>/g, '').replace(/&nbsp;/g, ' ').replace(/&amp;/g, '&').replace(/\s+/g, ' ').trim();
    };

    const getMetaValue = (key, text) => {
      const regex = new RegExp(key + '\\s*:\\s*([^.]+)', 'i');
      const match = regex.exec(text);
      return match ? match[1].trim() : "";
    };

    const zone = getMetaValue("Zone", description);
    const type = getMetaValue("Type", description);
    const category = getMetaValue("Category", description);
    const track = getMetaValue("Track", description);
    
    const pfMatch = /(\d+)\s*Platforms/i.exec(description);
    const platforms = pfMatch ? pfMatch[1] : "";
    
    const elevation = getMetaValue("Elevation", description);
    const address = getMetaValue("Station Address", description);
    const phone = getMetaValue("Tel", description);

    let code = "";
    let name = "";
    const anchorMatch = /<a\b[^>]*href="\/station\/map\/\d+"[^>]*>([\s\S]*?)<\/a>/i.exec(sinfo.StnDesc);
    if (anchorMatch) {
      const anchorText = cleanText(anchorMatch[1]);
      const parts = anchorText.split('/');
      if (parts.length >= 2) {
        code = parts[0].trim();
        name = parts[1].replace(/\(\d+\s*PFs?\)/gi, '').trim();
      }
    }

    // 4. Parse Follows
    const followsMatch = /(\d+)\s*Follows/i.exec(html);
    const follows = followsMatch ? parseInt(followsMatch[1], 10) : 0;

    // 5. Parse Overall Rating
    const ratingMatch = /Rating:\s*<span[^>]*>([\d.]+)<\/span>\/5\s*\((\d+)\s*votes\)/i.exec(html);
    const overallRating = ratingMatch ? parseFloat(ratingMatch[1]) : null;
    const ratingVotes = ratingMatch ? parseInt(ratingMatch[2], 10) : 0;

    // 6. Parse Pointwise Ratings
    const pointwise = {};
    const rtgRegex = /<div class="rtg\d">([^<]+)&nbsp;-&nbsp;([^&]+)&nbsp;\((\d+)\)<\/div>/gi;
    let rtgMatch;
    while ((rtgMatch = rtgRegex.exec(html)) !== null) {
      const categoryName = rtgMatch[1].replace(/&nbsp;/g, ' ').trim();
      const ratingName = rtgMatch[2].replace(/&nbsp;/g, ' ').trim();
      const votesCount = parseInt(rtgMatch[3].trim(), 10);
      pointwise[categoryName] = { rating: ratingName, votes: votesCount };
    }

    // 7. Parse Board Images with Captions
    const boards = [];
    const boardRegex = /<div style="display:none;margin-top:8px;border:1px dotted blue;">([\s\S]*?)<\/div><div class="boardunit"><a href="([^"]+)"[^>]*><img src="([^"]+)">/gi;
    let boardMatch;
    while ((boardMatch = boardRegex.exec(html)) !== null) {
      const captionText = boardMatch[1].replace(/&nbsp;/g, ' ').replace(/;\s*$/, '').trim();
      const fullUrl = boardMatch[2].trim();
      const thumbUrl = boardMatch[3].trim();
      boards.push({ caption: captionText, fullUrl, thumbUrl });
    }

    // 8. Extract all unique image URLs matching the pattern
    const imgPattern = /(?:https?:)?\/\/st\d*\.indiarailinfo\.com\/kjfdsuiemjvcya\d(?:\/\d+){6}\/[^\s"'><\\&]+/gi;
    const allImgUrls = html.match(imgPattern) || [];
    const uniqueImgs = [...new Set(allImgUrls)];

    // Construct formattedImages up to 6 images
    const formattedImages = [];
    
    // First add all boards images
    boards.forEach(b => {
      let url = b.fullUrl;
      if (!url.startsWith('http:') && !url.startsWith('https:')) {
        url = 'https:' + url;
      }
      formattedImages.push({
        url: url,
        caption: b.caption
      });
    });

    // Then add other unique images that are not board thumbnails and not already in formattedImages
    uniqueImgs.forEach(imgUrl => {
      if (formattedImages.length >= 6) return;
      
      let fullUrl = imgUrl;
      if (fullUrl.endsWith('_board.jpg')) {
        fullUrl = fullUrl.replace('_board.jpg', '.jpg');
      } else if (fullUrl.endsWith('_thumbnail.jpg')) {
        fullUrl = fullUrl.replace('_thumbnail.jpg', '.jpg');
      }

      if (!fullUrl.startsWith('http:') && !fullUrl.startsWith('https:')) {
        fullUrl = 'https:' + fullUrl;
      }

      const exists = formattedImages.some(fi => fi.url === fullUrl);
      if (!exists) {
        formattedImages.push({
          url: fullUrl,
          caption: "Station Photo"
        });
      }
    });

    // Fetch dynamic search images from DDG
    let searchQuery = "";
    if (name && code) {
      searchQuery = `${name} Railway Station ${code}`;
    } else if (title) {
      const cleanTitle = title.replace(/\s*Map\/Atlas[\s\S]*$/gi, '').replace(/\s*-\s*Railway[\s\S]*$/gi, '').trim();
      searchQuery = cleanTitle.includes("Station") ? cleanTitle : `${cleanTitle} Railway Station`;
    }

    let searchedImages = [];
    if (searchQuery) {
      searchedImages = await searchStationImages(searchQuery);
    }

    let finalImages = searchedImages;
    if (finalImages.length === 0) {
      finalImages = formattedImages;
    } else if (finalImages.length > 6) {
      finalImages = finalImages.slice(0, 6);
    }

    res.status(200).json({
      success: true,
      station: {
        id: String(id),
        code: code,
        name: name,
        title: title,
        latitude: latitude,
        longitude: longitude,
        zone: zone,
        type: type,
        category: category,
        track: track,
        platforms: platforms,
        elevation: elevation,
        address: address,
        phone: phone,
        description: description,
        follows: follows,
        rating: {
          value: overallRating,
          votes: ratingVotes
        },
        ratingPointwise: pointwise,
        images: finalImages,
        rawDescriptionHtml: sinfo.StnDesc
      }
    });

  } catch (error) {
    console.error("Indiarailinfo Details Error:", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

export const searchTrainsBetweenStations = async (req, res) => {
  try {
    const { src, dst, doj } = req.body;
    if (!src || !dst || !doj) {
      return res.status(400).json({ success: false, message: "Source, destination, and date of journey are required" });
    }

    const payload = {
      src: src.toUpperCase(),
      dst: dst.toUpperCase(),
      doj: doj, // YYYYMMDD
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

    res.status(200).json({
      success: true,
      data: response.data
    });
  } catch (error) {
    console.error("Search Trains Between Stations Error:", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};

// ─── Timetable Schedules Loading & Indexing ───────────────────────────
export let schedulesMap = {};
export let schedulesLoaded = false;

const loadSchedules = () => {
  try {
    console.time("Load Schedules");
    const schedulesPath = path.join(__dirname, "../data/schedules.json");
    if (fs.existsSync(schedulesPath)) {
      const data = JSON.parse(fs.readFileSync(schedulesPath, "utf8"));
      data.forEach(item => {
        const code = item.station_code ? item.station_code.trim().toUpperCase() : "";
        if (code) {
          if (!schedulesMap[code]) {
            schedulesMap[code] = [];
          }
          schedulesMap[code].push(item);
        }
      });
      schedulesLoaded = true;
      console.timeEnd("Load Schedules");
      console.log(`Loaded ${data.length} schedules, indexed by ${Object.keys(schedulesMap).length} stations.`);
    } else {
      console.warn("Schedules file not found at:", schedulesPath);
    }
  } catch (error) {
    console.error("Error loading schedules.json:", error);
  }
};

loadSchedules();

export const getStationBoard = async (req, res) => {
  try {
    const { stationCode } = req.params;
    const timeQuery = req.query.time; // Format "HH:mm" (optional)

    if (!stationCode) {
      return res.status(400).json({ success: false, message: "Station code is required" });
    }

    const code = stationCode.trim().toUpperCase();
    const stationSchedules = schedulesMap[code] || [];

    // Current time in minutes since midnight (Indian Standard Time)
    let nowMinutes;
    if (timeQuery && /^([01]\d|2[0-3]):[0-5]\d$/.test(timeQuery)) {
      const [h, m] = timeQuery.split(":").map(Number);
      nowMinutes = h * 60 + m;
    } else {
      const d = new Date();
      // Adjust server local/UTC time to IST (UTC +5:30)
      const utcTime = d.getTime() + (d.getTimezoneOffset() * 60000);
      const istDate = new Date(utcTime + (3600000 * 5.5));
      nowMinutes = istDate.getHours() * 60 + istDate.getMinutes();
    }

    const timeToMinutes = (tStr) => {
      if (!tStr || tStr === "None") return null;
      const parts = tStr.split(":");
      return Number(parts[0]) * 60 + Number(parts[1]);
    };

    const arrivingSoon = [];
    const atPlatform = [];
    const departedRecently = [];
    const nextTrains = [];

    // For statistics
    let arr30minCount = 0;
    let dep30minCount = 0;
    let totalTodayCount = stationSchedules.length;
    let lastDeparted = null;
    let firstTomorrow = null;
    let minTomorrowArr = 99999;
    let maxDepartedTime = -1;

    // Busy hours slots: 12 slots of 2 hours each
    const busySlots = Array(12).fill(0);

    for (const item of stationSchedules) {
      let arrMin = timeToMinutes(item.arrival);
      let depMin = timeToMinutes(item.departure);

      if (arrMin === null && depMin === null) continue;
      if (arrMin === null) arrMin = depMin;
      if (depMin === null) depMin = arrMin;

      // Group in busy hours (using departure time)
      const slotIndex = Math.floor(depMin / 120) % 12;
      busySlots[slotIndex]++;

      // 1. Arriving Soon: coming in next 60 minutes
      const timeToArrival = arrMin - nowMinutes;
      if (timeToArrival > 0 && timeToArrival <= 60) {
        arrivingSoon.push({
          ...item,
          timeToArrival,
          arrTimeFormatted: item.arrival.substring(0, 5),
          depTimeFormatted: item.departure.substring(0, 5)
        });
      }

      // 2. At Platform: arrival <= now <= departure
      if (arrMin <= nowMinutes && nowMinutes <= depMin) {
        const timeToDeparture = depMin - nowMinutes;
        atPlatform.push({
          ...item,
          timeToDeparture,
          arrTimeFormatted: item.arrival.substring(0, 5),
          depTimeFormatted: item.departure.substring(0, 5)
        });
      }

      // 3. Departed Recently: departed in last 30 minutes
      const timeSinceDeparture = nowMinutes - depMin;
      if (timeSinceDeparture > 0 && timeSinceDeparture <= 30) {
        departedRecently.push({
          ...item,
          timeSinceDeparture,
          arrTimeFormatted: item.arrival.substring(0, 5),
          depTimeFormatted: item.departure.substring(0, 5)
        });
      }

      // 4. Next Trains: arriving in next 60 to 180 mins
      if (timeToArrival > 60 && timeToArrival <= 180) {
        nextTrains.push({
          ...item,
          timeToArrival,
          arrTimeFormatted: item.arrival.substring(0, 5),
          depTimeFormatted: item.departure.substring(0, 5)
        });
      }

      // Stats calculations
      if (timeToArrival > 0 && timeToArrival <= 30) {
        arr30minCount++;
      }
      const timeToDepartureVal = depMin - nowMinutes;
      if (timeToDepartureVal > 0 && timeToDepartureVal <= 30) {
        dep30minCount++;
      }

      // Last departed train
      if (depMin <= nowMinutes && depMin > maxDepartedTime) {
        maxDepartedTime = depMin;
        lastDeparted = {
          ...item,
          timeSinceDeparture: nowMinutes - depMin,
          arrTimeFormatted: item.arrival.substring(0, 5),
          depTimeFormatted: item.departure.substring(0, 5)
        };
      }

      // First train tomorrow
      if (arrMin < minTomorrowArr) {
        minTomorrowArr = arrMin;
        firstTomorrow = {
          ...item,
          arrTimeFormatted: item.arrival.substring(0, 5),
          depTimeFormatted: item.departure.substring(0, 5)
        };
      }
    }

    // Format busy hours list
    const busyHours = [];
    for (let i = 0; i < 12; i++) {
      const startHour = String(i * 2).padStart(2, "0");
      const endHour = String((i + 1) * 2).padStart(2, "0");
      busyHours.push({
        slot: `${startHour}:00–${endHour}:00`,
        count: busySlots[i]
      });
    }

    // Sort outputs
    arrivingSoon.sort((a, b) => a.timeToArrival - b.timeToArrival);
    atPlatform.sort((a, b) => a.timeToDeparture - b.timeToDeparture);
    departedRecently.sort((a, b) => a.timeSinceDeparture - b.timeSinceDeparture);
    nextTrains.sort((a, b) => a.timeToArrival - b.timeToArrival);

    res.status(200).json({
      success: true,
      stationCode: code,
      currentTime: `${String(Math.floor(nowMinutes / 60)).padStart(2, "0")}:${String(nowMinutes % 60).padStart(2, "0")}`,
      arrivingSoon,
      atPlatform,
      departedRecently,
      nextTrains,
      stats: {
        arrivingNext30Min: arr30minCount,
        departingNext30Min: dep30minCount,
        currentlyAtStation: atPlatform.length,
        totalTrainsToday: totalTodayCount,
        lastDeparted,
        firstTomorrow,
        busyHours
      }
    });

  } catch (error) {
    console.error("Get Station Board Error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};


