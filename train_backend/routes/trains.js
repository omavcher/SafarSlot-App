const express = require('express');
const router = express.Router();
const trainController = require('../controllers/trainController');

router.post('/main', trainController.NearByRailwaySatation);
router.get('/train-search', trainController.TrainSearch);
router.get('/live-status', trainController.getTrainLiveStatus);
router.post('/pnr-status', trainController.getPnrStatus);
router.post('/train-composition', trainController.getTrainComposition);
// {
//   "trainNo": "11040",
//   "jDate": "2026-01-27",
//   "boardingStation": "NGP"
// }

router.post('/train-composition-by-coach', trainController.getCoachComposition);
// {
//   "trainNo": "11040",
//   "boardingStation": "NGP",
//   "remoteStation": "NGP",
//   "trainSourceStation": "G",
//   "jDate": "2026-01-27",
//   "coach": "B2",
//   "cls": "3A"
// }


router.get("/schedule", trainController.getTrainSchedule);

router.post("/station-info-upcoming", trainController.NearByRailwaySatationTrinsData);


router.post("/trains/prediction", trainController.searchTrainsWithLiveETA);
// {
//   "src": "NGP",
//   "dst": "NDLS",
//   "doj": "20260201"
// }


router.post("/next", trainController.getNextIncomingTrainAtSrc);

router.get("/stations/search", trainController.searchStations);

module.exports = router;