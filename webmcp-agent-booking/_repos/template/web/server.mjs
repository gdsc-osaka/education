// 座席・予約データは運営用予約API(booking-api)が持つため、このサーバーは
// public/ の静的ファイルを配信するだけのシンプルなHTTPサーバーになっている。
import { createServer } from "node:http";
import { readFile } from "node:fs/promises";
import { extname, join } from "node:path";
import { fileURLToPath } from "node:url";

const PORT = process.env.PORT ? Number(process.env.PORT) : 4000;
const PUBLIC_DIR = join(fileURLToPath(new URL(".", import.meta.url)), "public");

const CONTENT_TYPES = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
};

async function serveStatic(req, res, pathname) {
  const relativePath = pathname === "/" ? "/index.html" : pathname;
  const filePath = join(PUBLIC_DIR, relativePath);
  if (!filePath.startsWith(PUBLIC_DIR)) {
    res.writeHead(403).end("Forbidden");
    return;
  }
  try {
    const data = await readFile(filePath);
    const type = CONTENT_TYPES[extname(filePath)] ?? "application/octet-stream";
    res.writeHead(200, { "Content-Type": type });
    res.end(data);
  } catch {
    res.writeHead(404).end("Not Found");
  }
}

const server = createServer((req, res) => {
  const pathname = new URL(req.url, `http://${req.headers.host}`).pathname;
  serveStatic(req, res, pathname);
});

server.listen(PORT, () => {
  console.log(`座席予約サイト: http://localhost:${PORT}`);
  console.log("座席・予約データは booking-api (デフォルト: http://localhost:3001) から取得します。");
});
