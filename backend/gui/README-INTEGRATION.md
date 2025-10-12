Backend + React GUI integration

This small guide explains how the React GUI (under `src/` in backend) connects to the running API server on http://localhost:3000.

What was added
- `src/services/api.ts` — small fetch wrappers to `http://localhost:3000/api`.
- `src/App.tsx` — loads movies and genres and renders dynamic `Card` components.
- `src/ui/Header.tsx` — small input to paste a JWT token (used for protected endpoints).
- `src/ui/Controls.tsx` — search box wired to the movies endpoint.
- `src/ui/Card.tsx` — actions for adding to watchlist and posting a rating. These call protected endpoints and therefore require a valid JWT.

How to run
1. Make sure the API server is running on port 3000 (from repo `api`) — `pnpm start` in `api` folder.
2. Start the frontend dev server from the backend folder (if using Vite):

```bash
cd backend
pnpm install
pnpm dev
```

3. Open the UI (Vite will show the URL, usually http://localhost:5173). The frontend will fetch movies and genres from the backend API.

Testing protected endpoints
- Obtain a JWT by signing in through your API (or create one manually matching the API's auth). Paste the JWT into the input in the header.
- Click "Add" on a card to add to watchlist or "Rate 8" to post a rating. The UI will alert on success/failure.

Notes
- The UI is intentionally minimal and uses simple fetch calls. For production, add error handling, spinner states, pagination, and secure token storage.
