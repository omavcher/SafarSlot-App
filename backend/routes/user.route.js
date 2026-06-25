import express from 'express';
import { loginUser, signupUser, sendOtp, NearbyStation, userProfile, updateUserLanguage, updateUserLocation, updateUserNotification, saveRecentLiveTrain, getRecentLiveTrains, saveSavedRoute, getSavedRoutes, deleteSavedRoute } from '../controllers/user.controller.js';
import authMiddleware from '../middleware/auth.middleware.js';
import { CoachPosition } from '../controllers/train.controller.js';
const userRouter = express.Router();

userRouter.post("/send-otp", sendOtp);
userRouter.post("/sign-up",signupUser);
userRouter.post("/log-in",loginUser);

userRouter.post("/get-nearby-stations",NearbyStation);

userRouter.get("/coach-position",CoachPosition);

userRouter.get("/profile", authMiddleware, userProfile);
userRouter.put("/language", authMiddleware, updateUserLanguage);
userRouter.put("/location", authMiddleware, updateUserLocation);
userRouter.put("/notifications", authMiddleware, updateUserNotification);

userRouter.post("/recent-live-trains", authMiddleware, saveRecentLiveTrain);
userRouter.get("/recent-live-trains", authMiddleware, getRecentLiveTrains);

userRouter.post("/saved-routes", authMiddleware, saveSavedRoute);
userRouter.get("/saved-routes", authMiddleware, getSavedRoutes);
userRouter.delete("/saved-routes/:trainNo", authMiddleware, deleteSavedRoute);

export default userRouter;