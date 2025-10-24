module.exports = {
  content: ['./index.html', './**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        background: 'var(--bg)',
        'background-2': 'var(--bg-2)',
        foreground: 'var(--fg)',
        muted: {
          DEFAULT: 'var(--muted)',
          foreground: 'var(--muted)',
        },
        accent: {
          DEFAULT: 'var(--accent)',
          foreground: '#ffffff',
          secondary: 'var(--accent-2)',
        },
        card: {
          DEFAULT: 'var(--card)',
          foreground: 'var(--fg)',
        },
        border: 'var(--border)',
        ring: 'var(--ring)',
      },
    },
  },
  plugins: [],
};