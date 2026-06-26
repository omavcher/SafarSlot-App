import fs from 'fs';
import readline from 'readline';

async function inspect() {
  const fileStream = fs.createReadStream('data/schedules.json', { end: 2000 });
  fileStream.on('data', (chunk) => {
    console.log(chunk.toString());
  });
}
inspect();
