import { copyFileSync, mkdirSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';

const BOT_DIR = process.env.MAKEFUN_BOT_DIR ?? '/bot';
const OUTPUT_DIR = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

const srcPath = join(BOT_DIR, 'POST.json');
const dstPath = join(OUTPUT_DIR, 'POST.json');

let parsed: unknown;
try {
  const content = readFileSync(srcPath, 'utf8');
  parsed = JSON.parse(content);
} catch (err) {
  console.error(`POST.json could not be read or parsed: ${(err as Error).message}`);
  process.exit(1);
}

if (typeof parsed !== 'object' || parsed === null) {
  console.error('POST.json is not a JSON object');
  process.exit(1);
}

const { url } = parsed as Record<string, unknown>;
if (typeof url !== 'string' || url.length === 0) {
  console.error('POST.json missing or invalid url field: must be a non-empty string');
  process.exit(1);
}

mkdirSync(OUTPUT_DIR, { recursive: true });

try {
  copyFileSync(srcPath, dstPath);
} catch (err) {
  console.error(`POST.json could not be copied to ${OUTPUT_DIR}: ${(err as Error).message}`);
  process.exit(1);
}

const bytes = statSync(dstPath).size;
console.log(`POST.json copied (${bytes} bytes)`);