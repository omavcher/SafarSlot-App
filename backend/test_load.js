import fs from 'fs';
import path from 'path';

console.time('Load & Parse JSON');
const data = JSON.parse(fs.readFileSync('data/schedules.json', 'utf8'));
console.timeEnd('Load & Parse JSON');
console.log('Total items:', data.length);

console.time('Build Index');
const index = {};
for (const item of data) {
  const code = item.station_code;
  if (!index[code]) {
    index[code] = [];
  }
  index[code].push(item);
}
console.timeEnd('Build Index');
console.log('Total unique stations:', Object.keys(index).length);

const memoryUsage = process.memoryUsage();
console.log('Memory Usage:', {
  rss: `${Math.round(memoryUsage.rss / 1024 / 1024)} MB`,
  heapTotal: `${Math.round(memoryUsage.heapTotal / 1024 / 1024)} MB`,
  heapUsed: `${Math.round(memoryUsage.heapUsed / 1024 / 1024)} MB`
});
