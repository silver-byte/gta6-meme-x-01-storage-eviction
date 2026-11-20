# gta6-meme-x-01 make.fun competition entry

This repository contains the final entry image for the make.fun competition "gta6-meme-x-01".

## Input Assets

Two input assets are in `assets/`:

- **base-storage-eviction.webp** (1920x1280): AI-generated base scene showing a giant suitcase smashing into a TV cabinet, with game cases flying out. No text overlay.
- **mark-1024.png** (1024x1024): The official make.fun ghost mascot on a magenta disc, from the make.fun press kit (https://make.fun/press/).

## Output Images

The compositing program produces two output images in `output/`:

- **final-e.png** (1600x1000): The final competition entry image.
- **final-e-thumb768.png** (768x480): Thumbnail version for X/Twitter preview.

## Compositing Process

1. Draw the base image on an offscreen 1920x1280 canvas.
2. Composite the ghost mark onto the suitcase: centered at raw coordinates (883, 461), diameter 326 px, rotated -20 degrees to align with the suitcase tilt.
3. Crop/scale onto the final 1600x1000 canvas: source rect (0, 40, 1920, 1200) drawn to (0, 0, 1600, 1000).
4. Typeset three caption lines with canvas text:
   - y=26, start size 84, fill #FFFFFF: "GTA VI NEEDS HOW MUCH STORAGE?!"
   - y=830, start size 64, fill #FFFFFF: "EVERY OTHER GAME: EVICTED"
   - y=912, start size 50, fill #FF88C4: "THE GHOST MOVED IN AND GOT PAID - make.fun"
   Font: bold DejaVu Sans, textAlign center, textBaseline top, black stroke with lineJoin round and lineWidth = max(3, round(size/11)). Auto-fit: shrink size by 4 until measured width fits within 1500 px (floor size 18).
5. Export thumbnail: draw the finished 1600x1000 image into a 768x480 canvas.

## Reproduction

Run the capture script (requires Node.js, Chromium headless, Python 3):

```bash
./tools/shoot.sh
```

This starts a temporary static file server, runs headless Chromium to execute the compositing, saves the PNGs via HTTP POST endpoints, and prints SHA256 checksums.

The script is deterministic: running it twice produces identical SHA256 for `output/final-e.png`.

## Verification

```bash
# Verify PNG dimensions
node -e "
const fs = require('fs');
function p(b){const w=b.readUInt32BE(16),h=b.readUInt32BE(20);return{w,h};}
console.log('final-e.png:', p(fs.readFileSync('output/final-e.png')));
console.log('final-e-thumb768.png:', p(fs.readFileSync('output/final-e-thumb768.png')));
"
```

Expected:
```
final-e.png: { width: 1600, height: 1000 }
final-e-thumb768.png: { width: 768, height: 480 }
```

## Starter Files

- `main.ts` and `LICENSE` copied from `../gta6-meme-x-01-kit/starter/` (unchanged).