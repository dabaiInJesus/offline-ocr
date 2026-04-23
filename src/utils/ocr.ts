import Tesseract from 'tesseract.js'

// 支持的语言列表（26国语言）
export const SUPPORTED_LANGUAGES = {
  'chi_sim': '中文简体',
  'chi_tra': '中文繁体',
  'jpn': '日文',
  'kor': '韩文',
  'eng': '英文',
  'por': '葡萄牙语',
  'spa': '西班牙语',
  'fra': '法语',
  'deu': '德语',
  'ita': '意大利语',
  'rus': '俄语',
  'ara': '阿拉伯语',
  'hin': '印地语',
  'ben': '孟加拉语',
  'tha': '泰语',
  'vie': '越南语',
  'ind': '印尼语',
  'tur': '土耳其语',
  'pol': '波兰语',
  'nld': '荷兰语',
  'swe': '瑞典语',
  'dan': '丹麦语',
  'nor': '挪威语',
  'fin': '芬兰语',
}

// 常用语言组合（用于自动识别）
const LANGUAGE_GROUPS = {
  'asian': ['chi_sim', 'chi_tra', 'jpn', 'kor'],
  'european': ['eng', 'spa', 'fra', 'deu', 'ita', 'por', 'rus', 'pol', 'nld', 'swe', 'dan', 'nor', 'fin'],
  'other': ['ara', 'hin', 'ben', 'tha', 'vie', 'ind', 'tur']
}

// PSM (Page Segmentation Mode) 页面分割模式
export const PSMMode = {
  OSD_ONLY: 0,           // 仅方向和脚本检测
  AUTO_OSD: 1,           // 自动页面分割 + OSD
  AUTO_ONLY: 2,          // 仅自动页面分割（无OSD）
  AUTO: 3,               // 完全自动页面分割（默认）
  SINGLE_COLUMN: 4,      // 假设单列文本
  SINGLE_BLOCK_VERTICAL: 5, // 假设单个垂直对齐文本块
  SINGLE_BLOCK: 6,       // 假设单个文本块
  SINGLE_LINE: 7,        // 假设单行文本
  SINGLE_WORD: 8,        // 假设单个单词
  CIRCLE_WORD: 9,        // 假设圆形中的单个单词
  SINGLE_CHAR: 10,       // 假设单个字符
  SPARSE_TEXT: 11,       // 查找尽可能多的文本
  SPARSE_TEXT_OSD: 12,   // 稀疏文本 + OSD
  RAW_LINE: 13           // 原始行，保留布局信息
} as const

export type PSMMode = typeof PSMMode[keyof typeof PSMMode]

// OEM (OCR Engine Mode) OCR 引擎模式
export const OEMMode = {
  LEGACY_ONLY: 0,        // 仅使用旧版引擎
  LSTM_ONLY: 1,          // 仅使用LSTM神经网络引擎（推荐）
  TESSERACT_LSTM_COMBINED: 2, // 两者结合
  DEFAULT: 3             // 默认（基于可用内容）
} as const

export type OEMMode = typeof OEMMode[keyof typeof OEMMode]

export interface OCRResult {
  text: string
  confidence: number
  language: string
  duration: number
}

export interface OCRProgress {
  status: string
  progress: number
}

export interface OCROptions {
  lang?: string
  psm?: PSMMode // 页面分割模式
  oem?: OEMMode // OCR 引擎模式
  preprocess?: boolean // 是否启用图像预处理
}

/**
 * 图像预处理 - 提高识别准确率
 * @param image 原始图片
 * @returns 处理后的 Canvas
 */
function preprocessImage(image: HTMLImageElement | Blob): Promise<HTMLCanvasElement> {
  return new Promise((resolve) => {
    const canvas = document.createElement('canvas')
    const ctx = canvas.getContext('2d')!
    
    const img = image instanceof Blob ? new Image() : image
    
    if (image instanceof Blob) {
      const url = URL.createObjectURL(image)
      img.onload = () => {
        processCanvas(img, canvas, ctx)
        URL.revokeObjectURL(url)
        resolve(canvas)
      }
      img.src = url
    } else {
      processCanvas(img, canvas, ctx)
      resolve(canvas)
    }
  })
}

function processCanvas(img: HTMLImageElement, canvas: HTMLCanvasElement, ctx: CanvasRenderingContext2D) {
  // 放大图片（提高分辨率）
  const scale = 2
  canvas.width = img.width * scale
  canvas.height = img.height * scale
  
  // 高质量缩放
  ctx.imageSmoothingEnabled = true
  ctx.imageSmoothingQuality = 'high'
  ctx.drawImage(img, 0, 0, canvas.width, canvas.height)
  
  // 获取图像数据
  const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height)
  const data = imageData.data
  
  // 转换为灰度图并增强对比度
  for (let i = 0; i < data.length; i += 4) {
    // 灰度化（加权平均）
    const gray = 0.299 * data[i] + 0.587 * data[i + 1] + 0.114 * data[i + 2]
    
    // 二值化阈值处理（增强对比度）
    const threshold = 128
    const value = gray > threshold ? 255 : 0
    
    data[i] = value     // R
    data[i + 1] = value // G
    data[i + 2] = value // B
    // Alpha 保持不变
  }
  
  ctx.putImageData(imageData, 0, 0)
}

/**
 * 检测图片可能的语种
 * 使用快速扫描来推测语种
 */
async function detectLanguage(image: string | HTMLCanvasElement | HTMLImageElement | Blob): Promise<string[]> {
  // 首先尝试亚洲语言
  try {
    const asianResult = await Tesseract.recognize(
      image,
      'chi_sim+jpn+kor',
      {
        logger: () => {}, // 静默模式，提高性能
      }
    )
    
    if (asianResult.data.confidence > 60) {
      // 置信度高，返回亚洲语言
      return LANGUAGE_GROUPS.asian
    }
  } catch (e) {
    console.log('Asian detection failed')
  }

  // 尝试欧洲语言
  try {
    const euroResult = await Tesseract.recognize(
      image,
      'eng+spa+fra+deu',
      {
        logger: () => {},
      }
    )
    
    if (euroResult.data.confidence > 60) {
      return LANGUAGE_GROUPS.european
    }
  } catch (e) {
    console.log('European detection failed')
  }

  // 默认返回常用语言
  return ['eng', 'chi_sim', 'jpn']
}

/**
 * 单张图片OCR识别
 * @param image 图片路径、Canvas、Image或Blob
 * @param options OCR配置选项
 * @param onProgress 进度回调
 */
export async function recognizeImage(
  image: string | HTMLCanvasElement | HTMLImageElement | Blob,
  options?: OCROptions,
  onProgress?: (progress: OCRProgress) => void
): Promise<OCRResult> {
  const startTime = Date.now()
  
  // 图像预处理（如果启用）
  let processedImage = image
  if (options?.preprocess && !(image instanceof HTMLCanvasElement)) {
    try {
      processedImage = await preprocessImage(image as HTMLImageElement | Blob)
    } catch (e) {
      console.warn('Image preprocessing failed, using original image', e)
    }
  }
  
  // 如果没有指定语言，先进行快速检测
  let languages = options?.lang || 'eng'
  if (!options?.lang) {
    const detectedLangs = await detectLanguage(processedImage)
    languages = detectedLangs.join('+')
  }

  // 构建 Tesseract 配置
  const tesseractConfig: any = {
    logger: (m: any) => {
      if (onProgress) {
        onProgress({
          status: m.status,
          progress: m.progress || 0,
        })
      }
    },
  }
  
  // 设置 PSM 模式（页面分割）
  if (options?.psm !== undefined) {
    tesseractConfig.psm = options.psm
  }
  
  // 设置 OEM 模式（OCR引擎）
  if (options?.oem !== undefined) {
    tesseractConfig.oem = options.oem
  }

  // 执行OCR识别
  const result = await Tesseract.recognize(
    processedImage,
    languages,
    tesseractConfig
  )

  const duration = Date.now() - startTime

  return {
    text: result.data.text,
    confidence: result.data.confidence,
    language: options?.lang || 'auto-detected',
    duration,
  }
}

/**
 * 批量图片OCR识别
 * @param images 图片数组
 * @param options OCR配置选项
 * @param onProgress 进度回调
 */
export async function recognizeBatch(
  images: Array<string | HTMLCanvasElement | HTMLImageElement | Blob>,
  options?: OCROptions,
  onProgress?: (index: number, total: number, result: OCRResult) => void
): Promise<OCRResult[]> {
  const results: OCRResult[] = []
  const total = images.length

  for (let i = 0; i < total; i++) {
    try {
      const result = await recognizeImage(images[i], options)
      results.push(result)
      
      if (onProgress) {
        onProgress(i + 1, total, result)
      }
    } catch (error) {
      console.error(`Error processing image ${i + 1}:`, error)
      results.push({
        text: '',
        confidence: 0,
        language: options?.lang || 'error',
        duration: 0,
      })
    }
  }

  return results
}

/**
 * 预加载语言包（提高首次识别速度）
 * @param langs 要预加载的语言数组
 */
export async function preloadLanguages(langs: string[]): Promise<void> {
  const promises = langs.map(lang => {
    return Tesseract.createWorker(lang, 1, {
      logger: () => {},
    })
  })
  
  const workers = await Promise.all(promises)
  // 立即终止以释放资源，但语言包已缓存
  await Promise.all(workers.map(worker => worker.terminate()))
}
