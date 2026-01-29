const axios = require("axios");

exports.NearByRailwaySatation = async (req, res) => {
  try {
    const { latitude, longitude } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({
        message: "Latitude and Longitude are required"
      });
    }

    const url = "https://api.mapbox.com/search/searchbox/v1/forward";

    const response = await axios.get(url, {
      params: {
        q: "Railway",
        proximity: `${longitude},${latitude}`, // lng,lat
        limit: 5,
        access_token: process.env.MAPBOX_ACCESS_TOKEN
      }
    });

    const features = response.data.features || [];

    const stations = features
      .filter(f => f.properties?.feature_type === "poi")
      .map(f => ({
        name: f.properties.name,
        address: f.properties.full_address || f.properties.place_formatted,
        location: {
          latitude: f.properties.coordinates.latitude,
          longitude: f.properties.coordinates.longitude
        },
        distance: f.properties.distance
          ? `${(f.properties.distance / 1000).toFixed(2)} km`
          : "Unknown"
      }));

    res.status(200).json({
      success: true,
      count: stations.length,
      stations
    });

  } catch (error) {
    console.error("Mapbox Searchbox Error:", error.response?.data || error.message);

    res.status(500).json({
      message: "Server Error",
      details: error.response?.data || error.message
    });
  }
};



exports.TrainSearch = async (req, res) => {
  try {
    const { search } = req.query;

    if (!search) {
      return res.status(400).json({
        success: false,
        message: "Search query is required"
      });
    }

    const link = `https://www.redbus.in/railways/api/SolrTrainSearch?search=${encodeURIComponent(search)}`;

    const response = await axios.get(link);

    res.status(200).json({
      success: true,
      results: response.data.response
    });

  } catch (error) {
    console.error("Train Search Error:", error.message);

    res.status(500).json({
      success: false,
      message: "Server Error",
      details: error.response?.data || error.message
    });
  }
};



exports.getTrainLiveStatus = async (req, res) => {
  try {
    const { trainNo } = req.query;

    if (!trainNo) {
      return res.status(400).json({
        success: false,
        message: "trainNo is required"
      });
    }

    const url = `https://www.redbus.in/railways/api/getLtsDetails?trainNo=${trainNo}`;

    const response = await axios.get(url);

    res.status(200).json({
      success: true,
      data: response.data
    });

  } catch (error) {
    console.error("Train LTS Error:", error.message);

    res.status(500).json({
      success: false,
      message: "Server Error",
      details: error.response?.data || error.message
    });
  }
};


exports.getPnrStatus = async (req, res) => {
  try {
    const { pnr } = req.body;

    if (!pnr) {
      return res.status(400).json({
        success: false,
        message: "PNR number is required"
      });
    }

    const url = "https://www.redbus.in/rails/api/getPnrToolKitData";

    const response = await axios.post(
      url,
      { pnr }, // mobile not sent
      {
        headers: {
          "Content-Type": "application/json"
        }
      }
    );

    res.status(200).json({
      success: true,
      data: response.data
    });

  } catch (error) {
    console.error("PNR API Error:", error.message);

    res.status(500).json({
      success: false,
      message: "Server Error",
      details: error.response?.data || error.message
    });
  }
};


exports.getTrainComposition = async (req, res) => {
  try {
    const { trainNo, jDate, boardingStation } = req.body;

    if (!trainNo || !jDate || !boardingStation) {
      return res.status(400).json({
        success: false,
        message: "trainNo, jDate and boardingStation are required"
      });
    }

    const url = "https://www.irctc.co.in/online-charts/api/trainComposition";

    const response = await axios.post(
      url,
      {
        trainNo,
        jDate,
        boardingStation
      },
      {
        headers: {
          "Content-Type": "application/json",
          "User-Agent": "Mozilla/5.0",
          "Referer": "https://www.irctc.co.in/"
        }
      }
    );

    res.status(200).json({
      success: true,
      data: response.data
    });

  } catch (error) {
    console.error("Train Composition Error:", error.message);
    console.error(error.response?.data);

    res.status(500).json({
      success: false,
      message: "Server Error",
      details: error.response?.data || error.message
    });
  }
};


exports.getCoachComposition = async (req, res) => {
  try {
    const {
      trainNo,
      boardingStation,
      remoteStation,
      trainSourceStation,
      jDate,
      coach,
      cls
    } = req.body;

    if (!trainNo || !boardingStation || !remoteStation || !trainSourceStation || !jDate || !coach || !cls) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields"
      });
    }

    const url = "https://www.irctc.co.in/online-charts/api/coachComposition";

    const response = await axios.post(
      url,
      {
        trainNo,
        boardingStation,
        remoteStation,
        trainSourceStation,
        jDate,
        coach,
        cls
      },
      {
        headers: {
          "Content-Type": "application/json",
          "User-Agent": "Mozilla/5.0",
          "Referer": "https://www.irctc.co.in/"
        }
      }
    );

    res.status(200).json({
      success: true,
      data: response.data
    });

  } catch (error) {
    console.error("Coach Composition Error:", error.message);

    res.status(500).json({
      success: false,
      message: "Server Error",
      details: error.response?.data || error.message
    });
  }
};


exports.getTrainSchedule = async (req, res) => {
  try {
    const { trainNo } = req.query;

    if (!trainNo) {
      return res.status(400).json({
        success: false,
        message: "trainNo is required"
      });
    }

    // ✅ Use Redbus Live Train Status
    const url = `https://www.redbus.in/railways/api/getLtsDetails?trainNo=${trainNo}`;
    const response = await axios.get(url);
    const data = response.data;

    // 🔍 Extract stations from the correct path
    const stationsRaw = data?.stations || [];

    if (!Array.isArray(stationsRaw) || stationsRaw.length === 0) {
      return res.status(404).json({
        success: false,
        message: "No station data found for this train"
      });
    }

    // 🧹 Extract only station name + code
    const stations = stationsRaw.map(stn => ({
      stationName: stn.stationName || '',
      stationCode: stn.stationCode || ''
    })).filter(stn => stn.stationName && stn.stationCode); // Remove empty entries

    res.status(200).json({
      success: true,
      trainNo,
      trainName: data.trainName,
      totalStations: stations.length,
      stations
    });

  } catch (error) {
    console.error("Train Schedule Error:", error.message);
    
    // Handle different types of errors
    if (error.response) {
      // API returned an error response
      return res.status(error.response.status || 500).json({
        success: false,
        message: "Failed to fetch train schedule",
        details: error.response.data || error.message
      });
    } else if (error.request) {
      // Request was made but no response received
      return res.status(503).json({
        success: false,
        message: "Service unavailable. Please try again later."
      });
    } else {
      // Other errors
      return res.status(500).json({
        success: false,
        message: "Server Error",
        details: error.message
      });
    }
  }
};





const trinsWithCode = require("./trainswithcode");

exports.NearByRailwaySatationTrinsData = async (req, res) => {
  try {
    const { latitude, longitude } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({
        message: "Latitude and Longitude are required"
      });
    }

    const url = "https://api.mapbox.com/search/searchbox/v1/forward";

    const response = await axios.get(url, {
      params: {
        q: "Railway Station",
        proximity: `${longitude},${latitude}`,
        limit: 5,
        access_token: process.env.MAPBOX_ACCESS_TOKEN
      }
    });

    const features = response.data.features || [];

    // 🔹 STEP 1: Build matched station list
    const result = features
      .map((item) => {
        const stationName = item.properties?.name || "";

        const matchedStation = trinsWithCode.find(st =>
          stationName.toLowerCase().includes(st.name.toLowerCase())
        );

        if (!matchedStation) return null;

        return {
          stationCode: matchedStation.code,
          stationName: matchedStation.name,
          address: item.properties.full_address || "",
          latitude: item.geometry.coordinates[1],
          longitude: item.geometry.coordinates[0]
        };
      })
      .filter(Boolean);

    if (!result.length) {
      return res.status(404).json({
        success: false,
        message: "No matching railway station found"
      });
    }

    // 🔹 STEP 2: Count frequency
    const stationCount = {};
    for (const station of result) {
      stationCount[station.stationCode] =
        (stationCount[station.stationCode] || 0) + 1;
    }

    // 🔹 STEP 3: Find max occurring stationCode
    let maxStationCode = null;
    let maxCount = 0;

    for (const code in stationCount) {
      if (stationCount[code] > maxCount) {
        maxCount = stationCount[code];
        maxStationCode = code;
      }
    }

    // 🔹 STEP 4: Pick ONE station (first occurrence)
    const finalStation = result.find(
      s => s.stationCode === maxStationCode
    );

    // 🔹 STEP 5: Send ONLY one station
    res.status(200).json({
      success: true,
      station: finalStation
    });

  } catch (error) {
    console.error("Mapbox Error:", error.response?.data || error.message);
    res.status(500).json({
      message: "Server Error",
      details: error.response?.data || error.message
    });
  }
};

// 🇮🇳 Get current India (Mumbai) time
function getCurrentIST() {
  return new Date(
    new Date().toLocaleString("en-US", {
      timeZone: "Asia/Kolkata"
    })
  );
}

// ⏱ Convert train date + time → IST Date object
// dateStr: "01-02-2026", timeStr: "14:15"
function convertTrainToIST(dateStr, timeStr) {
  const [dd, mm, yyyy] = dateStr.split("-");
  return new Date(`${yyyy}-${mm}-${dd}T${timeStr}:00+05:30`);
}


exports.searchTrainsWithLiveETA = async (req, res) => {
  try {
    const { src, dst, doj } = req.body;

    if (!src || !dst || !doj) {
      return res.status(400).json({
        success: false,
        message: "src, dst, doj required"
      });
    }

    const searchUrl = "https://www.redbus.in/rails/api/searchResults";

    const searchPayload = {
      src,
      dst,
      doj,
      filter: {},
      sort: {},
      allowedQuotaList: [],
      enableRecaptcha: false,
      showConnectingTrains: false
    };

    const searchRes = await axios.post(searchUrl, searchPayload);
    const trainsRaw = searchRes.data?.trainBtwnStnsList || [];

    const nowIST = getCurrentIST();

    /* ---------- 1️⃣ FILTER ONLY UPCOMING TRAINS ---------- */
    const upcomingTrains = trainsRaw.filter(train => {
      const depIST = convertTrainToIST(
        train.departureDate,
        train.departureTime
      );
      return depIST > nowIST;
    });

    const trains = [];

    /* ---------- 2️⃣ LIVE ETA ONLY FOR VALID TRAINS ---------- */
    for (const train of upcomingTrains) {
      try {
        const ltsUrl = `https://www.redbus.in/railways/api/getLtsDetails?trainNo=${train.trainNumber}`;
        const ltsRes = await axios.get(ltsUrl);
        const lts = ltsRes.data;

        const stations = lts?.stations || [];
        if (!stations.length) continue;

        const lastPassed = stations
          .filter(s => s.hasDeparted)
          .slice(-1)[0];

        if (!lastPassed) continue;

        const srcStation = stations.find(s => s.stationCode === src);
        if (!srcStation) continue;

        const currentDistance = lastPassed.originDst;
        const srcDistance = srcStation.originDst;

        const remainingDistance = Math.max(
          srcDistance - currentDistance,
          0
        );

        const stationsRemaining = stations.filter(
          s => s.originDst > currentDistance && s.originDst <= srcDistance
        ).length;

        const avgSpeed =
          lastPassed.avgDelay !== undefined
            ? Math.max(40, 110 - lastPassed.avgDelay)
            : null;

        const etaHours =
          avgSpeed ? +(remainingDistance / avgSpeed).toFixed(2) : null;

        trains.push({
          trainNumber: train.trainNumber,
          trainName: train.trainName,
          departureTime: train.departureTime,
          live: {
            currentStation: lastPassed.stationName,
            remainingDistanceKm: remainingDistance,
            stationsRemaining,
            avgSpeedKmph: avgSpeed,
            etaHours,
            delayMins: lts.totalLateMins || 0
          }
        });

      } catch (err) {
        console.error("LTS skip:", train.trainNumber);
      }
    }

    res.status(200).json({
      success: true,
      currentIST: nowIST,
      totalUpcoming: trains.length,
      trains
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      details: error.message
    });
  }
};



exports.getNextIncomingTrainAtSrc = async (req, res) => {
  try {
    const { src, dst, doj } = req.body;

    if (!src || !dst || !doj) {
      return res.status(400).json({
        success: false,
        message: "src, dst and doj are required"
      });
    }

    const nowIST = getCurrentIST();

    // 1️⃣ Search trains
    const searchRes = await axios.post(
      "https://www.redbus.in/rails/api/searchResults",
      {
        src,
        dst,
        doj,
        filter: {},
        sort: {},
        allowedQuotaList: [],
        enableRecaptcha: false,
        showConnectingTrains: false
      },
      { headers: { "Content-Type": "application/json" } }
    );

    const trains = searchRes.data?.trainBtwnStnsList || [];

    let bestTrain = null;

    // 2️⃣ Loop trains
    for (const t of trains) {
      const depTime = new Date(
        `${doj.slice(0,4)}-${doj.slice(4,6)}-${doj.slice(6,8)}T${t.departureTime}:00+05:30`
      );

      // ❌ skip past trains
      if (depTime <= nowIST) continue;

      // 3️⃣ Live status
      const liveRes = await axios.get(
        `https://www.redbus.in/railways/api/getLtsDetails?trainNo=${t.trainNumber}`
      );

      const stations = liveRes.data?.stations || [];
      const srcStation = stations.find(s => s.stationCode === src);

      if (!srcStation || srcStation.hasArrived) continue;

      const currentIndex = stations.findIndex(s => s.hasDeparted);
      const srcIndex = stations.findIndex(s => s.stationCode === src);

      if (currentIndex === -1 || srcIndex === -1) continue;

      const remainingDistance =
        stations[srcIndex].originDst - stations[currentIndex].originDst;

      const avgSpeed =
        remainingDistance > 0
          ? Math.round(remainingDistance / 2) // simple fast estimate
          : null;

      const etaMinutes =
        avgSpeed ? Math.round((remainingDistance / avgSpeed) * 60) : null;

      const candidate = {
        trainNumber: t.trainNumber,
        trainName: t.trainName,
        src,
        scheduledArrival: t.departureTime,
        live: {
          currentStation: liveRes.data.currentlyAt,
          stationsRemaining: srcIndex - currentIndex,
          remainingDistanceKm: remainingDistance,
          avgSpeedKmph: avgSpeed,
          etaMinutes,
          expectedArrivalTime: etaMinutes
            ? new Date(nowIST.getTime() + etaMinutes * 60000)
                .toTimeString()
                .slice(0, 5)
            : null,
          delayMins: liveRes.data.totalLateMins || 0
        }
      };

      if (!bestTrain || etaMinutes < bestTrain.live.etaMinutes) {
        bestTrain = candidate;
      }
    }

    if (!bestTrain) {
      return res.status(200).json({
        success: true,
        message: "No upcoming trains found"
      });
    }

    res.status(200).json({
      success: true,
      currentIST: nowIST,
      train: bestTrain
    });

  } catch (error) {
    console.error("Next Train Error:", error.message);
    res.status(500).json({
      success: false,
      message: "Server Error",
      details: error.response?.data || error.message
    });
  }
};



const stations = require("./trainswithcode");

exports.searchStations = async (req, res) => {
  try {
    const { q } = req.query;

    if (!q || q.length < 1) {
      return res.status(200).json({
        success: true,
        results: []
      });
    }

    const query = q.toLowerCase();

    const results = stations
      .filter(st =>
        st.code.toLowerCase().startsWith(query) ||
        st.name.toLowerCase().includes(query)
      )
      .slice(0, 10) // 🔥 limit for autocomplete
      .map(st => ({
        code: st.code,
        name: st.name,
        label: `${st.name} (${st.code})` // 👈 frontend friendly
      }));

    res.status(200).json({
      success: true,
      count: results.length,
      results
    });

  } catch (error) {
    console.error("Station Autocomplete Error:", error.message);

    res.status(500).json({
      success: false,
      message: "Server Error"
    });
  }
};
