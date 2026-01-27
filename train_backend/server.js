const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
const port = 3000;
app.use(bodyParser.json());
app.use(cors());
require("dotenv").config();

app.use('/api/trains', require('./routes/trains'));


app.get('/', (req, res) => {
    res.send('Train Backend Server is running');
});
app.listen(port, '0.0.0.0', () => {
    console.log(`Train Backend Server is listening at http://localhost:${port}`);
});