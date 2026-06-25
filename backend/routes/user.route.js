import express from 'express'
import { loginUser, signupUser, sendOtp, NearbyStation, userProfile, updateUserLanguage, updateUserLocation } from '../controllers/user.controller.js';
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


export default userRouter;