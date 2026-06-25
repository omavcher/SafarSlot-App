import axios from 'axios';
async function test() {
  const URL = 'https://cttrainsapi.confirmtkt.com/api/v2/trains/stations/auto-suggestion?searchString=&sourceStnCode=&popularStnListLimit=15&preferredStnListLimit=6&Latitude=21.079997902530117&Longitude=79.12293275326972&channel=mweb&language=EN';
  const res = await axios.get(URL);
  console.log(JSON.stringify(res.data.data.stationList.slice(0,2), null, 2));
}
test();
