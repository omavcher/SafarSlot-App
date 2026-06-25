import express from "express"
const trainRouter = express();

import { getPNR, getTrainNameCode, liveTrainStatus, stationsList, reportTrain, CoachPosition } from "../controllers/train.controller.js";


trainRouter.get("/pnr-status",getPNR);
trainRouter.get("/trainlist/:search",stationsList);
trainRouter.get("/train-name-code/:search",getTrainNameCode)
trainRouter.get("/train-live-status/:trainNo",liveTrainStatus);
trainRouter.post("/report", reportTrain);
trainRouter.get("/coach-position", CoachPosition);


export default trainRouter;