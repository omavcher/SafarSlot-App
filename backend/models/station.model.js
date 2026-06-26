import mongoose from "mongoose";

const stationSchema = new mongoose.Schema({
  code: {
    type: String,
    required: true,
    unique: true,
    uppercase: true,
    trim: true,
    index: true,
  },
  name: {
    type: String,
    required: true,
  },
  zone: String,
  platforms: String,
  elevation: String,
  track: String,
  address: String,
  phone: String,
  category: String,
  images: [
    {
      url: String,
      caption: String,
    }
  ],
  rating: mongoose.Schema.Types.Mixed,
  ratingPointwise: mongoose.Schema.Types.Mixed,
}, { timestamps: true });

const Station = mongoose.models.Station || mongoose.model("Station", stationSchema);
export default Station;
