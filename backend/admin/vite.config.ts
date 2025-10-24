import { defineConfig } from 'vite'
import { config } from 'dotenv'

// Load environment variables from .env file
config()

export default defineConfig(async () => {
  const react = (await import('@vitejs/plugin-react')).default

  return {
    plugins: [react()],
    base: '/admin/',
    build: {
      outDir: '../public/admin',
      sourcemap: false,
      emptyOutDir: true
    },
    server: {
      port: process.env.PORT ? parseInt(process.env.PORT) : 3001,
      host: true, // Allow external access
      proxy: {
        '/api': {
          target: 'http://localhost:3000',
          changeOrigin: true
        }
      }
    }
  }
})
