<script setup lang="ts">
import { ref } from 'vue'
import SingleOCR from './components/SingleOCR.vue'
import BatchOCR from './components/BatchOCR.vue'

const activeTab = ref<'single' | 'batch'>('single')
</script>

<template>
  <div class="h-screen w-screen overflow-hidden bg-gray-50 dark:bg-gray-900 flex">
    <!-- 左侧边栏 -->
    <aside class="w-64 bg-white dark:bg-gray-800 border-r border-gray-200 dark:border-gray-700 flex flex-col shadow-lg">
      <!-- Logo 和标题 -->
      <div class="p-6 border-b border-gray-200 dark:border-gray-700">
        <div class="flex items-center gap-3 mb-2">
          <div class="p-2 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-xl">
            <span class="text-2xl">📝</span>
          </div>
          <h1 class="text-lg font-bold bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">
            OCR 工具
          </h1>
        </div>
        <p class="text-xs text-gray-500 dark:text-gray-400">离线识别 · 多语言支持</p>
      </div>
      
      <!-- 导航菜单 -->
      <nav class="flex-1 p-4 space-y-2">
        <button
          @click="activeTab = 'single'"
          :class="[
            'w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 font-medium',
            activeTab === 'single'
              ? 'bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-lg'
              : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700/50'
          ]"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
          <span>单张识别</span>
        </button>
        
        <button
          @click="activeTab = 'batch'"
          :class="[
            'w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 font-medium',
            activeTab === 'batch'
              ? 'bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-lg'
              : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700/50'
          ]"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
          </svg>
          <span>批量识别</span>
        </button>
      </nav>
      
      <!-- 底部信息 -->
      <div class="p-4 border-t border-gray-200 dark:border-gray-700">
        <div class="space-y-2 text-xs text-gray-500 dark:text-gray-400">
          <div class="flex items-center gap-2">
            <svg class="w-4 h-4 text-green-500" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
            </svg>
            <span>离线可用</span>
          </div>
          <div class="flex items-center gap-2">
            <svg class="w-4 h-4 text-blue-500" fill="currentColor" viewBox="0 0 20 20">
              <path d="M3 4a1 1 0 011-1h12a1 1 0 011 1v2a1 1 0 01-1 1H4a1 1 0 01-1-1V4zM3 10a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H4a1 1 0 01-1-1v-6zM14 9a1 1 0 00-1 1v6a1 1 0 001 1h2a1 1 0 001-1v-6a1 1 0 00-1-1h-2z"/>
            </svg>
            <span>26国语言</span>
          </div>
        </div>
      </div>
    </aside>
    
    <!-- 右侧主体内容 -->
    <main class="flex-1 overflow-hidden p-6 md:p-8">
      <SingleOCR v-if="activeTab === 'single'" />
      <BatchOCR v-else />
    </main>
  </div>
</template>
