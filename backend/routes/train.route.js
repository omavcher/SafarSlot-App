import express from "express"
const trainRouter = express();

import { getPNR, getTrainNameCode, liveTrainStatus, stationsList, reportTrain, CoachPosition, searchStationsIndiarailinfo, getStationDetailsIndiarailinfo, searchTrainsBetweenStations, getStationBoard } from "../controllers/train.controller.js";


trainRouter.get("/pnr-status",getPNR);
trainRouter.get("/trainlist/:search",stationsList);
trainRouter.get("/train-name-code/:search",getTrainNameCode)
trainRouter.get("/train-live-status/:trainNo",liveTrainStatus);
trainRouter.post("/report", reportTrain);
trainRouter.get("/coach-position", CoachPosition);
trainRouter.get("/stations/search/:search", searchStationsIndiarailinfo);
trainRouter.get("/stations/details/:id", getStationDetailsIndiarailinfo);
trainRouter.post("/search-between-stations", searchTrainsBetweenStations);
trainRouter.get("/station-board/:stationCode", getStationBoard);


export default trainRouter;