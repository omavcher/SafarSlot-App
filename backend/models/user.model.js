import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },

    password: {
      type: String,
      default: null,
    },

    googleId:{
        type:String,
        default:null,
    },

    provider: {
      type: String,
      enum: ["email", "google"],
      default: "email",
    },

    language: {
      type: String,
      default: "en",
    },

    location: {
      lat: {
        type: String,
      },
      long: {
        type: String,
      },
    },

    city: {
      type: String,
      default: "",
    },

    notifications: {
      type: Boolean,
      default: true,
    },

    fcmToken: {
      type: String,
      default: "",
    },

    profilePicture: {
      type: String,
      default: "",
    },

    savedRoutes: [
      {
        trainNo: { type: String, required: true },
        trainName: { type: String, required: true },
        source: { type: String, required: true },
        destination: { type: String, required: true },
        savedAt: { type: Date, default: Date.now },
      }
    ],

    favoriteStations: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Station",
      },
    ],

    isPremium: {
      type: Boolean,
      default: false,
    },

    lastLogin: {
      type: Date,
    },

    recentLiveTrains: [
      {
        trainNo: { type: String, required: true },
        trainName: { type: String, required: true },
        route: { type: String, required: true },
        searchedAt: { type: Date, default: Date.now },
      }
    ],
  },
  {
    timestamps: true,
  }
);

const User = mongoose.model("User", userSchema);

export default User;