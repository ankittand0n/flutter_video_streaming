import { defineConfig } from 'vite'
import { config } from 'dotenv'

// Load environment variables from .env file
config()

export default defineConfig(async () => {
  const react = (await import('@vitejs/plugin-react')).default

  return {
    plugins: [react()],
    server: {
      port: process.env.PORT ? parseInt(process.env.PORT) : 3000,
      host: true // Allow external access
    }
  }
})
