# RankTier backend

Saves each tier list so it comes back after a refresh.

You do **not** need a separate always-on VPS for the live Netlify site. Netlify Functions plus Netlify Blobs store lists there. Locally, this small Node server writes JSON files under `backend/data/`.

```bash
npm start
```

Then open http://127.0.0.1:8765/app/

- `GET /api/lists` — saved lists
- `GET /api/lists/:id` — one list
- `POST /api/lists` — create or update
- `DELETE /api/lists/:id` — delete

If the API is offline, the browser still remembers the current list in localStorage.
