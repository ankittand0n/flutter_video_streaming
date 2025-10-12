# Frontend React (Black & Red theme)

This is a minimal Vite + React app using Tailwind CSS and a simple theme provider that applies a black and red color scheme via CSS variables.

Quick start:

1. cd frontend-react
2. npm install
3. npm run dev

Windows (bash) example:

```bash
cd frontend-react
npm install
npm run dev
```

What to expect:
- Dev server on http://localhost:5173
- A minimal UI with a black & red theme controlled by CSS variables in `src/styles.css` and `src/theme/ThemeProvider.tsx`.

Notes:
- This is intentionally minimal. You can wire it into the existing Flutter frontend or host separately.
- Theme variables are in `src/styles.css` and `src/theme/ThemeProvider.tsx` sets them on document root.
