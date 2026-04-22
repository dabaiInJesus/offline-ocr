import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  base: './',
  server: {
    port: 5173,
    strictPort: true, // 如果端口被占用则报错，而不是自动切换
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
  },
})
