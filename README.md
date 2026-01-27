# Run Locally

## Docker Compose

From the project root:

```bash
docker-compose up -d
```

- **Backend:** http://localhost:5080  
- **Frontend:** http://localhost:8081  

Default login: `root@example.com` / `Complexpass#123`

## Frontend

**Location:** `web/`

- App and UI: `web/src/`
- Dev server (without Docker): `cd web && npm install && npm run dev`  
  Set `VITE_OPENOBSERVE_ENDPOINT=http://localhost:5080/` in `.env` so the UI talks to the backend.
