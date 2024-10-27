const fs = require('fs');
const obfuscator = require('javascript-obfuscator');

const args = process.argv.slice(2);
const input = args[0];
const output = args[1];

if (!input || !output) {
  console.error('NO FILE');
  process.exit(1);
}

const code = fs.readFileSync(input, 'utf8');
const obfuscationResult = obfuscator.obfuscate(code);
fs.writeFileSync(output, obfuscationResult.getObfuscatedCode(), 'utf8');

console.log('SUCCESS');