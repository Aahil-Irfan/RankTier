import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { deleteList, getList, listSummaries, saveList } from "./store.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const website = path.join(here, "..", "website");
const port = Number(process.env.PORT || 8765);
const maxBytes = 4_500_000;

const types = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".webp": "image/webp",
  ".txt": "text/plain; charset=utf-8",
  ".zip": "application/zip",
  ".exe": "application/octet-stream",
  ".deb": "application/vnd.debian.binary-package",
  ".rpm": "application/x-rpm",
  ".gz": "application/gzip",
  ".sh": "text/x-shellscript",
};

function send(res, status, body, headers = {}) {
  const payload = Buffer.isBuffer(body) || typeof body === "string" ? body : JSON.stringify(body);
  res.writeHead(status, {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET,POST,DELETE,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    ...headers,
  });
  res.end(payload);
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    let size = 0;
    req.on("data", (chunk) => {
      size += chunk.length;
      if (size > maxBytes) {
        reject(new Error("List is too large"));
        req.destroy();
        return;
      }
      chunks.push(chunk);
    });
    req.on("end", () => resolve(Buffer.concat(chunks).toString("utf8")));
    req.on("error", reject);
  });
}

async function handleApi(req, res, url) {
  if (req.method === "OPTIONS") {
    send(res, 204, "");
    return;
  }

  const parts = url.pathname.split("/").filter(Boolean);
  const id = parts[2];

  try {
    if (req.method === "GET" && parts[1] === "lists" && !id) {
      send(res, 200, await listSummaries(), { "Content-Type": "application/json; charset=utf-8" });
      return;
    }
    if (req.method === "GET" && parts[1] === "lists" && id) {
      const list = await getList(id);
      if (!list) {
        send(res, 404, { error: "Not found" }, { "Content-Type": "application/json; charset=utf-8" });
        return;
      }
      send(res, 200, list, { "Content-Type": "application/json; charset=utf-8" });
      return;
    }
    if (req.method === "POST" && parts[1] === "lists") {
      const data = JSON.parse(await readBody(req) || "{}");
      const saved = await saveList(data);
      send(res, 200, saved, { "Content-Type": "application/json; charset=utf-8" });
      return;
    }
    if (req.method === "DELETE" && parts[1] === "lists" && id) {
      const ok = await deleteList(id);
      send(res, ok ? 204 : 404, ok ? "" : { error: "Not found" }, ok ? {} : { "Content-Type": "application/json; charset=utf-8" });
      return;
    }
    send(res, 404, { error: "Unknown API route" }, { "Content-Type": "application/json; charset=utf-8" });
  } catch (err) {
    send(res, 400, { error: err.message || "Bad request" }, { "Content-Type": "application/json; charset=utf-8" });
  }
}

function serveStatic(req, res, url) {
  let filePath = path.join(website, decodeURIComponent(url.pathname));
  if (url.pathname.endsWith("/")) filePath = path.join(filePath, "index.html");
  if (!path.resolve(filePath).startsWith(path.resolve(website))) {
    send(res, 403, "Forbidden");
    return;
  }
  fs.stat(filePath, (err, stat) => {
    if (!err && stat.isDirectory()) filePath = path.join(filePath, "index.html");
    fs.readFile(filePath, (readErr, data) => {
      if (readErr) {
        send(res, 404, "Not found");
        return;
      }
      send(res, 200, data, { "Content-Type": types[path.extname(filePath)] || "application/octet-stream" });
    });
  });
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || "127.0.0.1"}`);
  if (url.pathname.startsWith("/api/")) {
    handleApi(req, res, url);
    return;
  }
  serveStatic(req, res, url);
});

server.listen(port, "127.0.0.1", () => {
  console.log(`RankTier running at http://127.0.0.1:${port}/`);
  console.log("Lists save to backend/data/");
});
