import fs from 'fs';

const html = fs.readFileSync('google_images.html', 'utf8');
console.log("HTML length:", html.length);
console.log(html);
