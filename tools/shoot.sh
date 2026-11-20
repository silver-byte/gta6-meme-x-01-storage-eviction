#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

mkdir -p output

PORT=$(python3 -c "import socket; s=socket.socket(); s.bind(('',0)); print(s.getsockname()[1]); s.close()")

READY_FILE=$(mktemp)
node -e "
const http = require('http');
const fs = require('fs');
const path = require('path');
const server = http.createServer((req, res) => {
  if (req.method === 'POST' && req.url === '/save/final') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      const b64 = body.replace(/^data:image\/png;base64,/, '');
      fs.writeFileSync('output/final-e.png', Buffer.from(b64, 'base64'));
      res.writeHead(200); res.end('ok');
    });
    return;
  }
  if (req.method === 'POST' && req.url === '/save/thumb') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      const b64 = body.replace(/^data:image\/png;base64,/, '');
      fs.writeFileSync('output/final-e-thumb768.png', Buffer.from(b64, 'base64'));
      res.writeHead(200); res.end('ok');
    });
    return;
  }
  let filePath = '.' + req.url;
  if (filePath === './') filePath = './index.html';
  filePath = path.join(process.cwd(), filePath);
  const ext = path.extname(filePath);
  const mime = {
    '.html': 'text/html',
    '.webp': 'image/webp',
    '.png': 'image/png',
    '.js': 'application/javascript',
    '.css': 'text/css',
    '.wasm': 'application/wasm'
  }[ext] || 'application/octet-stream';
  fs.readFile(filePath, (err, data) => {
    if (err) { res.writeHead(404); res.end('Not found'); return; }
    res.writeHead(200, {'Content-Type': mime});
    res.end(data);
  });
});
server.listen($PORT, () => {
  console.log('SERVER_READY');
  fs.writeFileSync('$READY_FILE', 'ready');
});
" &
SERVER_PID=$!

while [[ ! -f "$READY_FILE" ]]; do
  sleep 0.1
done
rm -f "$READY_FILE"

timeout -s KILL 90 /usr/lib/chromium/chromium --headless=new --no-sandbox --window-size=1600,1000 --virtual-time-budget=20000 --enable-logging=stderr "http://localhost:$PORT/" > /dev/null 2>&1 || true

for i in {1..60}; do
  if [[ -s output/final-e.png && -s output/final-e-thumb768.png ]]; then
    break
  fi
  sleep 1
done

kill $SERVER_PID 2>/dev/null || true
wait $SERVER_PID 2>/dev/null || true

if [[ ! -s output/final-e.png || ! -s output/final-e-thumb768.png ]]; then
  echo "Failed to save PNGs" >&2
  exit 1
fi

sha256sum output/final-e.png output/final-e-thumb768.png