import User from "../models/user.model.js";
import Otp from "../models/otp.model.js";
import axios from "axios";
import dotenv from "dotenv";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Preload 8,990 Indian Railway stations into memory (0 ms latency for lookups)
const stationsDataPath = path.join(__dirname, "../data/stations.json");
const localStationsData = JSON.parse(fs.readFileSync(stationsDataPath, "utf8"));
const localStations = localStationsData.features;

const locationCache = new Map(); // In-memory Redis-like cache

const getCityName = async (lat, long) => {
  try {
    // Round coordinates to 2 decimal places (~1.1km accuracy) for efficient caching
    const roundedLat = parseFloat(lat).toFixed(2);
    const roundedLong = parseFloat(long).toFixed(2);
    const cacheKey = `${roundedLat},${roundedLong}`;

    // 1. Check Cache
    if (locationCache.has(cacheKey)) {
      return locationCache.get(cacheKey);
    }

    // 2. Mapbox API Call
    const res = await axios.get(
      `https://api.mapbox.com/search/geocode/v6/reverse?longitude=${long}&latitude=${lat}&access_token=${process.env.MAP_BOX_TOKEN}`
    );

    let cityFeature = res.data.features.find(
      (f) => f.properties?.feature_type === "place"
    );
    
    if (!cityFeature) {
       cityFeature = res.data.features.find(
         (f) => ["locality", "neighborhood", "district"].includes(f.properties?.feature_type)
       );
    }

    if (cityFeature && cityFeature.properties) {
        const cityName = cityFeature.properties.name || "";
        const regionCode = cityFeature.properties.context?.region?.region_code || cityFeature.properties.context?.region?.name || "";
        
        if (cityName && regionCode) {
            const finalCity = `${cityName}, ${regionCode.split('-').pop()}`;
            // Save to Cache before returning
            locationCache.set(cacheKey, finalCity);
            return finalCity;
        }
        
        locationCache.set(cacheKey, cityName);
        return cityName;
    }

    return "";
  } catch (error) {
    console.log(error);
    return "";
  }
};

export const sendOtp = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ success: false, message: "Email is required" });
    }
    
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(409).json({ success: false, message: "User already exists" });
    }

    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();

    await Otp.deleteMany({ email });
    await new Otp({ email, otp: otpCode }).save();

    console.log(`\n========================================`);
    console.log(`[OTP] The OTP for ${email} is: ${otpCode}`);
    console.log(`========================================\n`);

    return res.status(200).json({
      success: true,
      message: "OTP sent successfully. Please check the backend console logs.",
    });
  } catch (error) {
    console.log("Send OTP Error", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

export const signupUser = async (req, res) => {
  try {
    const {
      name,
      email,
      password,
      language,
      location,
      notifications,
      provider,
      fcm_token,
      googleId,
      otp,
    } = req.body;

    const existingUser = await User.findOne({ email });

    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: "User already exists",
      });
    }

    if (provider === "email") {
      if (!otp) {
        return res.status(400).json({ success: false, message: "OTP is required" });
      }
      const existingOtp = await Otp.findOne({ email, otp });
      if (!existingOtp) {
        return res.status(400).json({ success: false, message: "Invalid or expired OTP" });
      }
      
      // Delete OTP after verification
      await Otp.deleteOne({ _id: existingOtp._id });
    }

    const lat = location?.lat || null;
    const long = location?.long || null;

    const city = (lat && long) ? await getCityName(lat, long) : "";

    let hashedPassword = null;

    if (provider === "email") {
      hashedPassword = await bcrypt.hash(password, 10);
    }

    const newUser = new User({
      name,
      email,
      password: hashedPassword,
      provider,
      googleId,
      language,
      location,
      city,
      notifications,
      fcmToken: fcm_token,
    });

      await newUser.save();

       const token = jwt.sign(
      {
        userId: newUser._id,
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "30d",
      }
    );

    return res.status(201).json({
      success: true,
      message: "Account Created Successfully",
      user: {
        id: newUser._id,
        name: newUser.name,
        email: newUser.email,
      },
    });
  } catch (err) {
    console.log(err);

    return res.status(500).json({
      success: false,
      message: "Internal Server Error",
    });
  }
};


export const loginUser = async (req,res) =>{
    try{
        const {email,password,provider, location, fcm_token, notifications, language} = req.body;
        const user = await User.findOne({email});
        if(!user){
          console.error("Login : User Not Found",email);
          return res.status(404).json({
          success: false,
          message: "User not found",
      });
        }
        let isMatch = false;
        if (provider == 'email') {
           isMatch = await bcrypt.compare(password, user.password);
        } else {
           isMatch = true;
        }

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Invalid Credentials",
      });
    }

    const lat = location?.lat || null;
    const long = location?.long || null;
    let city = user.city;
    if (lat && long) {
       const newCity = await getCityName(lat, long);
       if (newCity) city = newCity;
    }

    if (location) user.location = location;
    user.city = city;
    if (fcm_token) user.fcmToken = fcm_token;
    if (notifications !== undefined) user.notifications = notifications;
    if (language) user.language = language;

    await user.save();

    const token = jwt.sign(
      {
        userId: user._id,
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "30d",
      }
    );

    return res.status(200).json({
      success: true,
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        city: user.city,
      }
    });
    } catch (error) {
      console.log(error);
      return res.status(500).json({success:false,message:"Internal Server Error"});
    }
}

export const updateUserLocation = async (req, res) => {
    try {
        const { userId, location } = req.body;
        if (!location || !location.lat || !location.long) {
            return res.status(400).json({ success: false, message: "Invalid location data" });
        }

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ success: false, message: "User not found" });
        }

        const city = await getCityName(location.lat, location.long);

        user.location = location;
        user.city = city;
        await user.save();

        return res.status(200).json({
            success: true,
            city: user.city,
            location: user.location,
        });
    } catch (error) {
        console.log(error);
        return res.status(500).json({ success: false, message: "Internal Server Error" });
    }
};


export const userProfile = async (req,res)=>{
     try{
        const { userId } = req.body;
        const user = await User.findById(userId);
        if(!user){
          return res.status(404).json({success:false,message:"User Not Found"});
        }
        const userProfileDetils = {
          name:user.name,
          email:user.email,
          profilePicture:user?.profilePicture,
          language:user.language,
          city:user.city,
          location:user.location,
          notification:user.notifications,
          savedRoutes: user.savedRoutes?.length || 0,
          favoriteStations: user.favoriteStations?.length || 0,
          isPremium:user.isPremium
        }

        res.status(200).json({
          success:true,
          userProfileDetils,
        })

     }catch(err){
    console.log(err);

    return res.status(500).json({
      success: false,
      message: "Internal Server Error",
    });    
  }
}


export const NearbyStation = async (req,res)=>{
  try{
      // Support both GET query parameters and POST/GET JSON body
      let lat = req.body.lat || req.query.lat;
      let long = req.body.long || req.query.long;
      
      if (!lat || !long) {
        return res.status(400).json({success: false, message: "Latitude and longitude are required"});
      }

      lat = parseFloat(lat);
      long = parseFloat(long);

      // Calculate Haversine distance for all local stations
      const R = 6371; // Earth radius in km
      const maxDistanceKm = 160;
      let stationList = [];

      for (let i = 0; i < localStations.length; i++) {
        const station = localStations[i];
        if (!station.geometry || !station.geometry.coordinates) continue; // Skip stations without coordinates
        
        const stnLon = station.geometry.coordinates[0];
        const stnLat = station.geometry.coordinates[1];
        
        const dLat = (stnLat - lat) * (Math.PI / 180);
        const dLon = (stnLon - long) * (Math.PI / 180);
        const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                  Math.cos(lat * (Math.PI / 180)) * Math.cos(stnLat * (Math.PI / 180)) *
                  Math.sin(dLon / 2) * Math.sin(dLon / 2);
        const distanceKm = R * (2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)));

        if (distanceKm <= maxDistanceKm) {
          stationList.push({
            name: station.properties?.name || "Unknown Station",
            coordinates: [stnLon, stnLat],
            distance: Math.round(distanceKm * 1000), // meters
            
            // Legacy properties to ensure Flutter app compatibility
            stationCode: station.properties?.code || "N/A", 
            stationName: station.properties?.name || "Unknown Station",
            majorStn: true, // All stations in this JSON are IRCTC stations
            latitude: stnLat,
            longitude: stnLon,
            isMetro: false,
            zone: station.properties?.zone,
            state: station.properties?.state
          });
        }
      }

      if (stationList.length === 0) {
        return res.status(404).json({success: false, message: "No stations found within 160km"});
      }
      
      // Sort stations by distance ascending
      stationList.sort((a, b) => a.distance - b.distance);
      
      // Return top 15 nearest stations
      stationList = stationList.slice(0, 15);
      
      res.status(200).json({
        success: true,
        stations: stationList,
      });

   }catch(err){
      console.log("Error in NearbyStation API:", err?.message || err);
      return res.status(500).json({
        success: false,
        message: "Internal Server Error",
      });    
   }
}

export const updateUserLanguage = async (req, res) => {
  try {
    const { userId, language } = req.body;
    const user = await User.findByIdAndUpdate(userId, { language }, { new: true });
    if (!user) {
      return res.status(404).json({ success: false, message: "User Not Found" });
    }
    return res.status(200).json({ success: true, message: "Language updated", language: user.language });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
}