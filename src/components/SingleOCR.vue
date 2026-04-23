<script setup lang="ts">
import { ref, computed } from 'vue'
import { recognizeImage, SUPPORTED_LANGUAGES, PSMMode, OEMMode, type OCRProgress, type OCRResult, type OCROptions } from '../utils/ocr'

const selectedFile = ref<File | null>(null)
const imagePreview = ref<string>('')
const isRecognizing = ref(false)
const progress = ref<OCRProgress>({ status: '', progress: 0 })
const result = ref<OCRResult | null>(null)
const selectedLang = ref<string>('') // 空字符串表示自动检测

// 高级选项（暂时隐藏，保留以备将来使用）
// const showAdvanced = ref(false)
const enablePreprocess = ref(true) // 默认启用图像预处理
const selectedPSM = ref<PSMMode | ''>('') // 页面分割模式
const selectedOEM = ref<OEMMode | ''>('') // OCR引擎模式
const fileInput = ref<HTMLInputElement>()

// 触发文件选择
const triggerFileSelect = () => {
  fileInput.value?.click()
}

// 处理文件选择
const handleFileSelect = (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  
  if (!file) return
  
  selectedFile.value = file
  
  // 创建预览
  const reader = new FileReader()
  reader.onload = (e) => {
    imagePreview.value = e.target?.result as string
  }
  reader.readAsDataURL(file)
  
  // 重置结果
  result.value = null
  progress.value = { status: '', progress: 0 }
}

// 执行OCR识别
const handleRecognize = async () => {
  if (!selectedFile.value) return
  
  isRecognizing.value = true
  result.value = null
  
  try {
    // 构建 OCR 选项
    const options: OCROptions = {
      lang: selectedLang.value || undefined,
      preprocess: enablePreprocess.value,
    }
    
    // 添加 PSM 模式（如果选择）
    if (selectedPSM.value !== '') {
      options.psm = selectedPSM.value as PSMMode
    }
    
    // 添加 OEM 模式（如果选择）
    if (selectedOEM.value !== '') {
      options.oem = selectedOEM.value as OEMMode
    }
    
    const ocrResult = await recognizeImage(
      selectedFile.value,
      options,
      (p) => {
        progress.value = p
      }
    )
    
    result.value = ocrResult
  } catch (error) {
    console.error('OCR识别失败:', error)
    alert('OCR识别失败，请重试')
  } finally {
    isRecognizing.value = false
  }
}

// 清除选择
const handleClear = () => {
  selectedFile.value = null
  imagePreview.value = ''
  result.value = null
  progress.value = { status: '', progress: 0 }
}

// 复制结果
const handleCopy = () => {
  if (result.value?.text) {
    navigator.clipboard.writeText(result.value.text)
    alert('已复制到剪贴板')
  }
}

const hasImage = computed(() => !!imagePreview.value)
</script>

<template>
  <div class="h-full bg-white/90 dark:bg-gray-800/90 backdrop-blur-md rounded-2xl shadow-2xl p-4 md:p-6 border border-gray-200/50 dark:border-gray-700/50 flex flex-col overflow-hidden">
    <div class="flex items-center gap-3 mb-4 flex-shrink-0">
      <div class="p-2 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-xl">
        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
      </div>
      <h2 class="text-xl md:text-2xl font-bold bg-gradient-to-r from-gray-800 to-gray-600 dark:from-white dark:to-gray-300 bg-clip-text text-transparent">
        单张图片OCR识别
      </h2>
    </div>
    
    <!-- 语言选择和高级选项 -->
    <div class="mb-3 flex-shrink-0 grid grid-cols-2 md:grid-cols-4 gap-2">
      <!-- 语言选择 -->
      <div>
        <label class="flex items-center gap-1.5 text-xs font-semibold text-gray-700 dark:text-gray-200 mb-1">
          <svg class="w-3 h-3 text-blue-500" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M7 2a1 1 0 00-.707 1.707L7 4.414v3.758a1 1 0 01-.293.707l-4 4C.817 14.769 2.156 18 4.828 18c2.67 0 4.012-3.231 2.122-5.121L5.5 11.414V7.586L7 6.122a1 1 0 00.707-1.707 7.002 7.002 0 00-7.414 0A1 1 0 007 2z" clip-rule="evenodd"/>
            <path fill-rule="evenodd" d="M13 2a1 1 0 00-.707 1.707L13 4.414v3.758a1 1 0 01-.293.707l-4 4c-1.89 1.89-.55 5.121 2.122 5.121 2.67 0 4.012-3.231 2.122-5.121l-1.45-1.464V7.586L13 6.122a1 1 0 00.707-1.707 7.002 7.002 0 00-7.414 0A1 1 0 0013 2z" clip-rule="evenodd"/>
          </svg>
          语言
        </label>
        <select
          v-model="selectedLang"
          class="w-full px-2 py-1.5 border border-gray-200 dark:border-gray-600 rounded-lg focus:ring-1 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700/50 dark:text-white transition-all duration-200 hover:border-blue-400 text-xs"
        >
          <option value="">🔍 自动检测</option>
          <option v-for="(name, code) in SUPPORTED_LANGUAGES" :key="code" :value="code">
            {{ name }}
          </option>
        </select>
      </div>
      
      <!-- PSM 模式 -->
      <div>
        <label class="flex items-center gap-1.5 text-xs font-semibold text-gray-700 dark:text-gray-200 mb-1">
          <svg class="w-3 h-3 text-purple-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 10h16M4 14h16M4 18h16" />
          </svg>
          PSM
        </label>
        <select
          v-model="selectedPSM"
          class="w-full px-2 py-1.5 border border-gray-200 dark:border-gray-600 rounded-lg focus:ring-1 focus:ring-purple-500 focus:border-purple-500 dark:bg-gray-700/50 dark:text-white transition-all duration-200 hover:border-purple-400 text-xs"
        >
          <option :value="''">自动</option>
          <option :value="PSMMode.AUTO">完全自动</option>
          <option :value="PSMMode.SINGLE_COLUMN">单列文本</option>
          <option :value="PSMMode.SINGLE_BLOCK">单个块</option>
          <option :value="PSMMode.SINGLE_LINE">单行</option>
          <option :value="PSMMode.SPARSE_TEXT">稀疏</option>
        </select>
      </div>
      
      <!-- OEM 模式 -->
      <div>
        <label class="flex items-center gap-1.5 text-xs font-semibold text-gray-700 dark:text-gray-200 mb-1">
          <svg class="w-3 h-3 text-indigo-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
          </svg>
          OEM
        </label>
        <select
          v-model="selectedOEM"
          class="w-full px-2 py-1.5 border border-gray-200 dark:border-gray-600 rounded-lg focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700/50 dark:text-white transition-all duration-200 hover:border-indigo-400 text-xs"
        >
          <option :value="''">默认</option>
          <option :value="OEMMode.LSTM_ONLY">LSTM（推荐）</option>
          <option :value="OEMMode.TESSERACT_LSTM_COMBINED">T+L结合</option>
          <option :value="OEMMode.LEGACY_ONLY">旧版</option>
        </select>
      </div>
      
      <!-- 图像预处理 -->
      <div class="flex items-end">
        <label class="flex items-center gap-2 cursor-pointer bg-gradient-to-br from-gray-50 to-blue-50/50 dark:from-gray-900/50 dark:to-blue-900/20 p-2 rounded-lg border border-gray-200/50 dark:border-gray-700/50 w-full">
          <input
            type="checkbox"
            v-model="enablePreprocess"
            class="w-3.5 h-3.5 text-blue-600 rounded focus:ring-blue-500"
          />
          <div class="flex-1 min-w-0">
            <div class="text-xs font-semibold text-gray-700 dark:text-gray-200 flex items-center gap-1">
              <svg class="w-3 h-3 text-green-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
              预处理
            </div>
            <p class="text-[9px] text-gray-500 dark:text-gray-500 mt-0.5 truncate">灰度+二值化+放大</p>
          </div>
        </label>
      </div>
    </div>
    
    <!-- 可滚动内容区域 -->
    <div class="flex-1 overflow-y-auto min-h-0 pr-1">
      <!-- 图片上传区域 -->
    <div
      class="group relative border-3 border-dashed border-gray-300 dark:border-gray-600 rounded-2xl p-6 md:p-8 text-center hover:border-blue-500 dark:hover:border-blue-400 hover:bg-blue-50/30 dark:hover:bg-blue-900/10 transition-all duration-300 cursor-pointer mb-4"
      @click="triggerFileSelect"
    >
      <input
        ref="fileInput"
        type="file"
        accept="image/*"
        class="hidden"
        @change="handleFileSelect"
      />
      
      <div v-if="!hasImage" class="space-y-3">
        <div class="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-blue-100 to-indigo-100 dark:from-blue-900/30 dark:to-indigo-900/30 rounded-2xl group-hover:scale-110 transition-transform duration-300">
          <svg class="w-8 h-8 text-blue-600 dark:text-blue-400" stroke="currentColor" fill="none" viewBox="0 0 48 48">
            <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
          </svg>
        </div>
        <div class="text-gray-600 dark:text-gray-300">
          <span class="font-semibold text-blue-600 dark:text-blue-400">点击上传</span> 或拖拽图片到此处
        </div>
        <p class="text-xs text-gray-500 dark:text-gray-500 flex items-center justify-center gap-1">
          <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>
          </svg>
          支持 PNG、JPG、GIF、WebP 等格式
        </p>
      </div>
      
      <div v-else class="relative group/image">
        <img :src="imagePreview" alt="预览" class="max-h-48 md:max-h-64 mx-auto rounded-xl shadow-lg" />
        <button
          @click.stop="handleClear"
          class="absolute top-3 right-3 bg-red-500 hover:bg-red-600 text-white rounded-full p-2 shadow-lg hover:shadow-xl transform hover:scale-110 transition-all duration-200"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
    </div>
    
    <!-- 识别按钮 -->
    <div class="mt-4 flex gap-3 flex-shrink-0">
      <button
        @click="handleRecognize"
        :disabled="!hasImage || isRecognizing"
        class="flex-1 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 disabled:from-gray-400 disabled:to-gray-500 text-white px-8 py-3 rounded-xl shadow-lg hover:shadow-xl disabled:shadow-none disabled:cursor-not-allowed transition-all duration-300 font-semibold flex items-center justify-center gap-2 transform hover:scale-[1.02] active:scale-[0.98]"
      >
        <svg v-if="!isRecognizing" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
        </svg>
        <svg v-else class="animate-spin w-5 h-5" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        <span v-if="isRecognizing">识别中...</span>
        <span v-else>开始识别</span>
      </button>
      
      <button
        @click="handleClear"
        :disabled="!hasImage"
        class="px-8 py-3 border-2 border-gray-300 dark:border-gray-600 rounded-xl hover:bg-gray-100 dark:hover:bg-gray-700/50 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 font-semibold dark:text-white hover:border-gray-400 dark:hover:border-gray-500"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
        </svg>
      </button>
    </div>
    
    <!-- 进度条 -->
    <div v-if="isRecognizing" class="mt-4 flex-shrink-0">
      <div class="flex justify-between text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        <span class="flex items-center gap-2">
          <svg class="w-4 h-4 animate-spin text-blue-500" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          {{ progress.status }}
        </span>
        <span class="text-blue-600 dark:text-blue-400 font-bold">{{ Math.round(progress.progress * 100) }}%</span>
      </div>
      <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-3 overflow-hidden shadow-inner">
        <div
          class="bg-gradient-to-r from-blue-500 to-indigo-600 h-3 rounded-full transition-all duration-300 ease-out relative"
          :style="{ width: `${progress.progress * 100}%` }"
        >
          <div class="absolute inset-0 bg-white/30 animate-pulse"></div>
        </div>
      </div>
    </div>
    
    <!-- 识别结果 -->
    <div v-if="result" class="mt-6 animate-fade-in">
      <div class="flex items-center justify-between mb-3">
        <h3 class="text-xl font-bold text-gray-800 dark:text-white flex items-center gap-2">
          <svg class="w-6 h-6 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          识别结果
        </h3>
        <button
          @click="handleCopy"
          class="inline-flex items-center gap-2 px-4 py-2 bg-blue-50 hover:bg-blue-100 dark:bg-blue-900/30 dark:hover:bg-blue-900/50 text-blue-600 dark:text-blue-400 rounded-lg transition-all duration-200 font-medium text-sm"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
          </svg>
          复制文本
        </button>
      </div>
      
      <div class="bg-gradient-to-br from-gray-50 to-blue-50/30 dark:from-gray-900/50 dark:to-blue-900/20 border-2 border-gray-200 dark:border-gray-700 rounded-xl p-5 shadow-inner">
        <pre class="whitespace-pre-wrap text-gray-800 dark:text-gray-200 text-sm leading-relaxed font-mono">{{ result.text }}</pre>
      </div>
      
      <div class="mt-4 flex flex-wrap gap-3 text-sm">
        <div class="inline-flex items-center gap-2 px-4 py-2 bg-green-50 dark:bg-green-900/20 rounded-lg border border-green-200 dark:border-green-800">
          <svg class="w-4 h-4 text-green-600 dark:text-green-400" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
          </svg>
          <span class="text-green-700 dark:text-green-400 font-semibold">置信度: {{ result.confidence.toFixed(2) }}%</span>
        </div>
        <div class="inline-flex items-center gap-2 px-4 py-2 bg-blue-50 dark:bg-blue-900/20 rounded-lg border border-blue-200 dark:border-blue-800">
          <svg class="w-4 h-4 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span class="text-blue-700 dark:text-blue-400 font-semibold">耗时: {{ result.duration }}ms</span>
        </div>
        <div class="inline-flex items-center gap-2 px-4 py-2 bg-purple-50 dark:bg-purple-900/20 rounded-lg border border-purple-200 dark:border-purple-800">
          <svg class="w-4 h-4 text-purple-600 dark:text-purple-400" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M7 2a1 1 0 00-.707 1.707L7 4.414v3.758a1 1 0 01-.293.707l-4 4c-1.89 1.89-.55 5.121 2.122 5.121 2.67 0 4.012-3.231 2.122-5.121l-1.45-1.464V7.586L7 6.122a1 1 0 00.707-1.707 7.002 7.002 0 00-7.414 0A1 1 0 007 2z" clip-rule="evenodd"/>
          </svg>
          <span class="text-purple-700 dark:text-purple-400 font-semibold">语言: {{ result.language }}</span>
        </div>
      </div>
    </div>
    </div>
  </div>
</template>
