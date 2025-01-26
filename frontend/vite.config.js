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
    proxy: {
      '/api': 'http://localhost:8000',
    }
  }
})