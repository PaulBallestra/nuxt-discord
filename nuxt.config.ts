// https://nuxt.com/docs/api/configuration/nuxt-config
import tailwindcss from '@tailwindcss/vite'
import glsl from 'vite-plugin-glsl'

export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  modules: ['@nuxtjs/supabase', '@nuxt/ui'],
  css: [
    './app/assets/styles/global.css'
  ],
  vite: {
    assetsInclude: ['**/*.glsl', '**/*.vert', '**/*.frag'],
    plugins: [
      glsl(),
      tailwindcss(),
    ]
  },
  supabase: {
    redirectOptions: {
      login: '/login',
      callback: '/confirm',
      include: undefined,
      exclude: ['/', '/stickers'],
      saveRedirectToCookie: false,
    }
  }
})