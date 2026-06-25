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

export const getPNR = async (req,res)=>{
    try{
        const {pnr}=req.body;
        if (pnr.length !== 10) {
  return res.status(400).json({
    success: false,
    message: "Please Provide Correct PNR",
  });
}
        const URL = `https://cttrainsapi.confirmtkt.com/api/v2/ctpro/mweb/${pnr}?querysource=ct-mweb&locale=en&getHighChanceText=true&livePnr=false`
       const response = await axios.post(URL, { proPlanName: "" });
       const pnrDetails = response.data?.data?.pnrResponse || response.data;
       res.status(200).json({
        success:true,
        message:"PNR Status Fetched Successfully",
        data: pnrDetails
       });
    }catch(error){
        console.error("Get PNR Error", error.message);
        res.status(500).json({success:false,message:error.message})
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
