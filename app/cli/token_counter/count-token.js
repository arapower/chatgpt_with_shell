const {encode, decode} = require('gpt-3-encoder')
const fs = require('fs');
const path = require('path');

// Get script name and command line arguments
const scriptName = path.basename(__filename);
const arg1 = process.argv[2];
const arg2 = process.argv[3];

// If no arguments are specified, output usage and exit
if (!arg1) {
  console.log('Usage: node script.js [-f <file path>] <text to process>\nOutput: Number of tokens');
  return;
}

// If arg1 is '-f', process the contents of a file
if (arg1 === '-f') {
  // Ensure arg2 is a file path
  if (!arg2) {
    console.error('File path not specified.');
    return;
  }

  // Read the contents of the file
  fs.readFile(arg2, 'utf-8', (err, data) => {
    if (err) {
      console.error(err);
      return;
    }

    // Process the file contents
    processText(data);
  });
}
// If arg1 is not '-f', process the specified text
else {
  // Process the text specified in arg1
  processText(arg1);
}

// Function to process a text string
function processText(text) {
  const encoded = encode(text)
  console.log(encoded.length)
}

