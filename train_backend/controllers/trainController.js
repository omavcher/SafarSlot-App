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

