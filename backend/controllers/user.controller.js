import User from "../models/user.model.js";
import Otp from "../models/otp.model.js";
import Station from "../models/station.model.js";
import { schedulesMap } from "./train.controller.js";
import axios from "axios";
import dotenv from "dotenv";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import {
  localStations,
  getStationNamesByCode,
  getLocalizedNameByCode,
  pickLocalizedName,
} from "../utils/localization.js";

dotenv.config();

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


export const updateUserNotification = async (req, res) => {
    try {
        const { userId, notifications } = req.body;
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ success: false, message: "User not found" });
        }
        
        user.notifications = notifications;

        // When turning OFF notifications, clear the FCM token so no push is sent
        if (!notifications) {
            user.fcmToken = null;
        }

        await user.save();

        return res.status(200).json({
            success: true,
            notifications: user.notifications,
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
          savedRoutes: (user.savedRoutes || []).length,
          favoriteStations: (user.favoriteStations || []).length,
          recentTrainSearches: (user.recentTrainSearches || []).length,
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
          const lang = req.body.lang || req.query.lang || req.headers['accept-language'];
          const stationCode = station.properties?.code || "N/A";
          const stationNames = getStationNamesByCode(stationCode);
          const localizedName = stationNames
            ? pickLocalizedName(stationNames, lang)
            : (station.properties?.name || "Unknown Station");
          stationList.push({
            name: localizedName,
            coordinates: [stnLon, stnLat],
            distance: Math.round(distanceKm * 1000), // meters
            
            // Legacy properties to ensure Flutter app compatibility
            stationCode,
            stationName: localizedName,
            stationNames: stationNames || undefined,
            majorStn: true, // All stations in this JSON are IRCTC stations
            latitude: stnLat,
            longitude: stnLon,
            isMetro: false,
            zone: station.properties?.zone,
            state: station.properties?.state,

            // Schedule tracking properties
            hasSchedules: (station.properties?.code && schedulesMap[station.properties.code.toUpperCase()] && schedulesMap[station.properties.code.toUpperCase()].length > 0) ? true : false,
            trainCount: (station.properties?.code && schedulesMap[station.properties.code.toUpperCase()]) ? schedulesMap[station.properties.code.toUpperCase()].length : 0
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

export const saveRecentLiveTrain = async (req, res) => {
  try {
    const userId = req.body.userId;
    const { trainNo, trainName, route } = req.body;

    if (!trainNo || !trainName || !route) {
      return res.status(400).json({ success: false, message: "Missing required fields" });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    // Initialize array if undefined
    if (!user.recentLiveTrains) {
      user.recentLiveTrains = [];
    }

    // Remove if already exists so we can bump it to the top
    user.recentLiveTrains = user.recentLiveTrains.filter(t => t.trainNo !== trainNo);

    // Add to the beginning of the array
    user.recentLiveTrains.unshift({
      trainNo,
      trainName,
      route,
      searchedAt: new Date()
    });

    // Keep only the 20 most recent
    if (user.recentLiveTrains.length > 20) {
      user.recentLiveTrains = user.recentLiveTrains.slice(0, 20);
    }

    await user.save();
    return res.status(200).json({ success: true, message: "Saved to recent live trains", data: user.recentLiveTrains });
  } catch (error) {
    console.log("Save Recent Live Train Error", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

export const getRecentLiveTrains = async (req, res) => {
  try {
    const userId = req.body.userId;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    const recent = user.recentLiveTrains || [];
    return res.status(200).json({ success: true, data: recent });
  } catch (error) {
    console.log("Get Recent Live Trains Error", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

export const saveSavedRoute = async (req, res) => {
  try {
    const userId = req.body.userId;
    const { trainNo, trainName, source, destination } = req.body;

    if (!trainNo || !trainName || !source || !destination) {
      return res.status(400).json({ success: false, message: "Missing required fields" });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    if (!user.savedRoutes) {
      user.savedRoutes = [];
    }

    // Check if already saved
    const exists = user.savedRoutes.some(r => r.trainNo === trainNo);
    if (exists) {
      return res.status(400).json({ success: false, message: "Route already saved" });
    }

    user.savedRoutes.unshift({
      trainNo,
      trainName,
      source,
      destination,
      savedAt: new Date()
    });

    await user.save();
    return res.status(200).json({ success: true, message: "Route saved successfully", data: user.savedRoutes });
  } catch (error) {
    console.log("Save Saved Route Error", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

export const getSavedRoutes = async (req, res) => {
  try {
    const userId = req.body.userId;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    const lang = req.query.lang || (req.body && req.body.lang) || req.headers['accept-language'];
    const localizeRouteString = (routeStr, langCode) => {
      if (!routeStr) return routeStr;
      const match = /\(([A-Z0-9]+)\)/.exec(routeStr);
      if (match) {
        const code = match[1];
        const locName = getLocalizedNameByCode(code, langCode);
        if (locName) {
          return `${locName} (${code})`;
        }
      }
      return routeStr;
    };

    const routes = (user.savedRoutes || []).map(r => {
      const routeObj = r.toObject ? r.toObject() : r;
      routeObj.source = localizeRouteString(routeObj.source, lang);
      routeObj.destination = localizeRouteString(routeObj.destination, lang);
      return routeObj;
    });

    return res.status(200).json({ success: true, data: routes });
  } catch (error) {
    console.log("Get Saved Routes Error", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

export const deleteSavedRoute = async (req, res) => {
  try {
    const userId = req.body.userId;
    const { trainNo } = req.params;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    if (!user.savedRoutes) {
      user.savedRoutes = [];
    }

    user.savedRoutes = user.savedRoutes.filter(r => r.trainNo !== trainNo);
    await user.save();

    return res.status(200).json({ success: true, message: "Route deleted successfully", data: user.savedRoutes });
  } catch (error) {
    console.log("Delete Saved Route Error", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

export const saveFavoriteStation = async (req, res) => {
  try {
    const userId = req.body.userId;
    const { 
      stationCode, 
      stationName,
      zone,
      platforms,
      elevation,
      track,
      address,
      phone,
      category,
      images,
      rating,
      ratingPointwise 
    } = req.body;

    if (!stationCode || !stationName) {
      return res.status(400).json({ success: false, message: "Missing required fields (stationCode, stationName)" });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    let station = await Station.findOne({ code: stationCode.toUpperCase() });
    if (!station) {
      station = new Station({
        code: stationCode,
        name: stationName,
        zone,
        platforms,
        elevation,
        track,
        address,
        phone,
        category,
        images,
        rating,
        ratingPointwise
      });
      await station.save();
    } else {
      if (zone) station.zone = zone;
      if (platforms) station.platforms = platforms;
      if (elevation) station.elevation = elevation;
      if (track) station.track = track;
      if (address) station.address = address;
      if (phone) station.phone = phone;
      if (category) station.category = category;
      if (images) station.images = images;
      if (rating) station.rating = rating;
      if (ratingPointwise) station.ratingPointwise = ratingPointwise;
      await station.save();
    }

    if (!user.favoriteStations) {
      user.favoriteStations = [];
    }

    if (!user.favoriteStations.includes(station._id)) {
      user.favoriteStations.push(station._id);
      await user.save();
    }

    return res.status(200).json({ success: true, message: "Station favorited successfully", data: station });
  } catch (error) {
    console.log("Save Favorite Station Error", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

export const deleteFavoriteStation = async (req, res) => {
  try {
    const userId = req.body.userId;
    const { stationCode } = req.params;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    const station = await Station.findOne({ code: stationCode.toUpperCase() });
    if (!station) {
      return res.status(404).json({ success: false, message: "Station not found in database" });
    }

    if (user.favoriteStations) {
      user.favoriteStations = user.favoriteStations.filter(
        id => id.toString() !== station._id.toString()
      );
      await user.save();
    }

    return res.status(200).json({ success: true, message: "Station removed from favorites successfully" });
  } catch (error) {
    console.log("Delete Favorite Station Error", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

export const getFavoriteStations = async (req, res) => {
  try {
    const userId = req.body.userId;
    const user = await User.findById(userId).populate("favoriteStations");
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    const lang = req.query.lang || (req.body && req.body.lang) || req.headers['accept-language'];
    const favorites = (user.favoriteStations || []).map(station => {
      const stationObj = station.toObject ? station.toObject() : station;
      if (stationObj.code) {
        const names = getStationNamesByCode(stationObj.code);
        if (names) {
          stationObj.stationNames = names;
          stationObj.name = pickLocalizedName(names, lang);
          stationObj.stationName = stationObj.name;
        }
      }
      return stationObj;
    });

    return res.status(200).json({ success: true, data: favorites });
  } catch (error) {
    console.log("Get Favorite Stations Error", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

export const saveRecentTrainSearch = async (req, res) => {
  try {
    const userId = req.body.userId;
    const { fromCode, fromName, toCode, toName, date, travelClass } = req.body;

    if (!fromCode || !fromName || !toCode || !toName) {
      return res.status(400).json({ success: false, message: "Missing required fields" });
    }

    // Pull duplicates atomically (prevents concurrent VersionError)
    await User.updateOne(
      { _id: userId },
      {
        $pull: {
          recentTrainSearches: { fromCode, toCode }
        }
      }
    );

    // Prepend new search and slice to 20 elements atomically
    await User.updateOne(
      { _id: userId },
      {
        $push: {
          recentTrainSearches: {
            $each: [{
              fromCode,
              fromName,
              toCode,
              toName,
              date: date || "",
              travelClass: travelClass || "All Classes",
              searchedAt: new Date()
            }],
            $position: 0,
            $slice: 20
          }
        }
      }
    );

    // Fetch the updated document safely
    const updatedUser = await User.findById(userId);
    if (!updatedUser) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    return res.status(200).json({ success: true, message: "Saved to recent searches", data: updatedUser.recentTrainSearches });
  } catch (error) {
    console.log("Save Recent Train Search Error", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

export const getRecentTrainSearches = async (req, res) => {
  try {
    const userId = req.body.userId;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    const lang = req.query.lang || (req.body && req.body.lang) || req.headers['accept-language'];
    const recent = (user.recentTrainSearches || []).map(s => {
      const searchObj = s.toObject ? s.toObject() : s;
      if (searchObj.fromCode) {
        const names = getStationNamesByCode(searchObj.fromCode);
        if (names) {
          searchObj.fromNames = names;
          searchObj.fromName = pickLocalizedName(names, lang);
        }
      }
      if (searchObj.toCode) {
        const names = getStationNamesByCode(searchObj.toCode);
        if (names) {
          searchObj.toNames = names;
          searchObj.toName = pickLocalizedName(names, lang);
        }
      }
      return searchObj;
    });
    return res.status(200).json({ success: true, data: recent });
  } catch (error) {
    console.log("Get Recent Train Searches Error", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

export const saveRecentStationSearch = async (req, res) => {
  try {
    const userId = req.body.userId;
    const { stationCode, stationName } = req.body;

    if (!stationCode || !stationName) {
      return res.status(400).json({ success: false, message: "Missing stationCode or stationName" });
    }

    // Pull duplicates atomically (prevents concurrent VersionError)
    await User.updateOne(
      { _id: userId },
      {
        $pull: {
          recentStationSearches: { stationCode }
        }
      }
    );

    // Prepend new search and slice to 20 elements atomically
    await User.updateOne(
      { _id: userId },
      {
        $push: {
          recentStationSearches: {
            $each: [{
              stationCode,
              stationName,
              searchedAt: new Date()
            }],
            $position: 0,
            $slice: 20
          }
        }
      }
    );

    // Fetch the updated document safely
    const updatedUser = await User.findById(userId);
    if (!updatedUser) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    return res.status(200).json({ success: true, message: "Saved recent station search", data: updatedUser.recentStationSearches });
  } catch (error) {
    console.log("Save Recent Station Search Error", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

export const getRecentStationSearches = async (req, res) => {
  try {
    const userId = req.body.userId;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    const lang = req.query.lang || (req.body && req.body.lang) || req.headers['accept-language'];
    const recent = (user.recentStationSearches || []).map(s => {
      const searchObj = s.toObject ? s.toObject() : s;
      if (searchObj.stationCode) {
        const names = getStationNamesByCode(searchObj.stationCode);
        if (names) {
          searchObj.stationNames = names;
          searchObj.stationName = pickLocalizedName(names, lang);
        }
      }
      return searchObj;
    });
    return res.status(200).json({ success: true, data: recent });
  } catch (error) {
    console.log("Get Recent Station Searches Error", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};






