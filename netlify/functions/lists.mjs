import { getStore } from "@netlify/blobs";

const headers = {
  "Content-Type": "application/json; charset=utf-8",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET,POST,DELETE,OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

function normalizeType(type) {
  if (type === "iceberg" || type === "iceberg-drawn") return "iceberg";
  return "classic";
}

function json(status, body) {
  return { statusCode: status, headers, body: JSON.stringify(body) };
}

function listIdFromPath(pathname) {
  const parts = String(pathname || "").split("/").filter(Boolean);
  const idx = parts.lastIndexOf("lists");
  return idx >= 0 ? parts[idx + 1] : undefined;
}

function summary(data) {
  return {
    id: data.id,
    type: normalizeType(data.type),
    title: data.title || "Untitled list",
    updatedAt: data.updatedAt,
    itemCount: Object.keys(data.items || {}).length,
  };
}

export async function handler(event) {
  if (event.httpMethod === "OPTIONS") {
    return { statusCode: 204, headers, body: "" };
  }

  const store = getStore("ranktier-lists");
  const id = listIdFromPath(event.path);

  try {
    if (event.httpMethod === "GET" && !id) {
      const listed = await store.list();
      const summaries = [];
      for (const blob of listed.blobs || []) {
        const data = await store.get(blob.key, { type: "json" });
        if (data?.id) summaries.push(summary(data));
      }
      summaries.sort((a, b) => String(b.updatedAt).localeCompare(String(a.updatedAt)));
      return json(200, summaries);
    }

    if (event.httpMethod === "GET" && id) {
      const data = await store.get(id, { type: "json" });
      return data ? json(200, data) : json(404, { error: "Not found" });
    }

    if (event.httpMethod === "POST") {
      const incoming = JSON.parse(event.body || "{}");
      if (!incoming.id) return json(400, { error: "Missing list id" });
      const record = {
        id: incoming.id,
        type: normalizeType(incoming.type),
        title: String(incoming.title || "Untitled list").slice(0, 80),
        updatedAt: new Date().toISOString(),
        order: incoming.order || {},
        items: incoming.items || {},
      };
      await store.setJSON(record.id, record);
      return json(200, record);
    }

    if (event.httpMethod === "DELETE" && id) {
      await store.delete(id);
      return { statusCode: 204, headers, body: "" };
    }

    return json(404, { error: "Unknown API route" });
  } catch (err) {
    return json(400, { error: err.message || "Bad request" });
  }
}
