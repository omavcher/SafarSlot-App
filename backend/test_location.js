import axios from 'axios';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
dotenv.config({ path: 'C:/Users/Om Awchar/Documents/Safar Slot/backend/.env' });

async function test() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    const db = mongoose.connection.db;
    
    // Find a user
    const user = await db.collection('users').findOne({});
    console.log("User from DB:", user.name, "City:", user.city, "Location:", user.location);

    if (!user) {
       console.log("No user found");
       process.exit(0);
    }

    const { default: jwt } = await import('jsonwebtoken');
    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET);

    // Call update location
    console.log("Calling update location...");
    const locRes = await axios.put('http://localhost:8080/api/v1/user/location', {
      location: { lat: 19.0760, long: 72.8777 } // Mumbai
    }, {
      headers: { Authorization: Bearer  }
    });

    console.log("Location Res:", locRes.data);

  } catch(e) {
    console.error("Error:", e.response ? e.response.data : e.message);
  } finally {
    mongoose.disconnect();
  }
}

test();
