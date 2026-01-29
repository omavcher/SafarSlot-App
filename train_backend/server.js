const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
const port = 3000;
app.use(bodyParser.json());
app.use(cors());
require("dotenv").config();
const axios = require('axios');0

app.use('/api/trains', require('./routes/trains'));



// Website reload configuration
const url = process.env.RELOAD_URL || "https://heartecho-d851.onrender.com";
const interval = 90000;

function reloadWebsite() {
  axios
    .get(url)
    .then((response) => {
      console.log("website reloaded");
    })
    .catch((error) => {
      console.error(`Error: ${error.message}`);
    });
}

setInterval(reloadWebsite, interval);

app.get('/', (req, res) => {
    res.send('Train Backend Server is running');
});
app.listen(port, '0.0.0.0', () => {
    console.log(`Train Backend Server is listening at http://localhost:${port}`);
});