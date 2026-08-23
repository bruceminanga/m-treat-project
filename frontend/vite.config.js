// frontend/vite.config.js
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  build: {
    outDir: path.resolve(__dirname, '../static/dist'),
    emptyOutDir: true,
    assetsDir: '',
    manifest: true,
    rollupOptions: {
      input: path.resolve(__dirname, 'src/main.jsx'),
      output: {
        entryFileNames: 'main.js',
        chunkFileNames: '[name].[hash].js',
        assetFileNames: (assetInfo) => {
          if (assetInfo.name.endsWith('.css')) {
            return 'main.css';
          }
          return '[name].[ext]';
        }
      }
    }
  },
  server: {
    host: '0.0.0.0',      // 1. Allows Docker port forwarding to reach Vite
    port: 5173,
    strictPort: true,
    watch: {
      usePolling: true,   // 2. Ensures Hot Reload (HMR) triggers across Docker file mounts
    },
    proxy: {
      '/api': {
        // ⚠️ See explanation below for Docker proxy targets
        target: process.env.VITE_BACKEND_URL || 'http://localhost:8000',
        changeOrigin: true,
      },
    }
  }
})