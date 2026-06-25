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
        type: mongoose.Schema.Types.ObjectId,
        ref: "SavedRoute",
      },
    ],

    savedRoutes: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "PnrStatus",
      },
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
  },
  {
    timestamps: true,
  }
);

const User = mongoose.model("User", userSchema);

export default User;