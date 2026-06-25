import { getCityName } from './controllers/user.controller.js';
async function run() {
  const city = await getCityName(19.0760, 72.8777);
  console.log("Mumbai:", city);
  const city2 = await getCityName(21.1458, 79.0882);
  console.log("Nagpur:", city2);
}
run();
