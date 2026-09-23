import { mkdir, readFile, readdir, unlink, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.join(path.dirname(fileURLToPath(import.meta.url)), "data");

async function ensureDir() {
  await mkdir(root, { recursive: true });
}

function normalizeType(type) {
  if (type === "iceberg" || type === "iceberg-drawn") return "iceberg";
  if (type === "canvas" || type === "blank") return "canvas";
  if (type === "custom" || type === "make") return "custom";
  return "classic";
}

function sanitizeTiers(raw) {
  if (!Array.isArray(raw)) return [];
  const colors = ["#ff4f4f", "#ff8c2e", "#ffcc33", "#8cd652", "#61baf2", "#ba9eed", "#f472b6", "#94a3b8"];
  return raw.slice(0, 20).map((tier, i) => ({
    id: /^[a-zA-Z0-9-]{2,40}$/.test(tier?.id) ? tier.id : `row-${i + 1}`,
    label: String(tier?.label || `Row ${i + 1}`).slice(0, 24),
    color: /^#[0-9a-fA-F]{6}$/.test(tier?.color) ? tier.color : colors[i % colors.length],
  }));
}

function listPath(id) {
  if (!/^[a-zA-Z0-9-]{8,80}$/.test(id)) {
    throw new Error("Invalid list id");
  }
  return path.join(root, `${id}.json`);
}

export async function listSummaries() {
  await ensureDir();
  const names = await readdir(root);
  const summaries = [];
  for (const name of names) {
    if (!name.endsWith(".json") || name === "index.json") continue;
    const raw = await readFile(path.join(root, name), "utf8");
    const data = JSON.parse(raw);
    summaries.push({
      id: data.id,
      type: normalizeType(data.type),
      title: data.title || "Untitled list",
      updatedAt: data.updatedAt,
      itemCount: Object.keys(data.items || {}).length,
    });
  }
  summaries.sort((a, b) => String(b.updatedAt).localeCompare(String(a.updatedAt)));
  return summaries;
}

export async function getList(id) {
  await ensureDir();
  try {
    return JSON.parse(await readFile(listPath(id), "utf8"));
  } catch (err) {
    if (err.code === "ENOENT") return null;
    throw err;
  }
}

export async function saveList(data) {
  await ensureDir();
  if (!data || !data.id) throw new Error("Missing list id");
  const record = {
    id: data.id,
    type: normalizeType(data.type),
    title: String(data.title || "Untitled list").slice(0, 80),
    updatedAt: new Date().toISOString(),
    order: data.order || {},
    items: data.items || {},
    tiers: ["canvas", "custom"].includes(normalizeType(data.type)) ? sanitizeTiers(data.tiers) : undefined,
  };
  await writeFile(listPath(record.id), JSON.stringify(record));
  return record;
}

export async function deleteList(id) {
  await ensureDir();
  try {
    await unlink(listPath(id));
    return true;
  } catch (err) {
    if (err.code === "ENOENT") return false;
    throw err;
  }
}
