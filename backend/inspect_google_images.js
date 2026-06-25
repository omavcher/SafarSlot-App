import fs from 'fs';

const html = fs.readFileSync('google_images.html', 'utf8');

// Replace all escaped slashes to make regex matching easier
const unescapedHtml = html.replace(/\\\/|\\u002f/g, '/');

// Find all URLs matching images
const regex = /(https?:\/\/[^\s"'><\\{}()[\]]+?\.(?:jpg|png|jpeg))/gi;
const matches = unescapedHtml.match(regex) || [];
const uniqueMatches = [...new Set(matches)];

console.log("Unescaped Matches count:", uniqueMatches.length);
console.log("First 30 matches:");
uniqueMatches.slice(0, 30).forEach((url, i) => {
  console.log(`${i}: ${url}`);
});
