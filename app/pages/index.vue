<script setup lang="ts">
const client = useSupabaseClient()
const isAnimated = ref(false);
const isHover = ref(false)

const { data: instruments } = await useAsyncData('instrument', async () => {
  const { data } = await client.from('instruments').select('id, name')
  return data
})
</script>

<template>
  <ul v-if="instruments">
    <li v-for="instrument in instruments" :key="instrument.id">{{ instrument.name }}</li>
  </ul>

<div 
    @pointerenter="isHover = true"
    @pointerleave="isHover = false"
    class="sticker relative w-[473px] h-[421px] overflow-hidden"
  >
    <!-- Base sticker -->
    <div
      class="w-full h-full bg-center bg-cover bg-no-repeat"
      :style="{ 'background-image': 'url(/sticker.png)' }"
    ></div>

    <!-- Shine effect -->
    <div
      v-if="isHover"
      class="absolute inset-0 animate-shine"
      :style="{
        '-webkit-mask-image': 'url(/sticker-mask.png)',
        'mask-image': 'url(/sticker-mask.png)',
        'mask-repeat': 'no-repeat',
        'mask-size': 'cover',
        'background': 'linear-gradient(120deg, rgba(255,255,255,0.4), rgba(255,255,255,0))'
      }"
    ></div>

    <!-- Holographic effect -->
    <!-- <div
      v-if="isHover"
      class="absolute inset-0 animate-holo"
      :style="{
        '-webkit-mask-image': 'url(/sticker-mask.png)',
        'mask-image': 'url(/sticker-mask.png)',
        'mask-repeat': 'no-repeat',
        'mask-size': 'cover',
        'background': 'conic-gradient(from 0deg, #f0f, #0ff, #ff0, #f0f)'
      }"
    ></div> -->
  </div>

</template>

<style>
.sticker {
  position: relative;
  overflow: hidden;
  background-image: var(--base-img);
  background-size: cover;
  background-position: center;
}

.sticker.animated {
  /* background: red; */
  transform: scale(1.03);
}

/* MASK LAYER */
.sticker::before {
  content: "";
  position: absolute;
  inset: 0;
  background-image: var(--mask-img);

  /* important: only animate/affect this layer */
  mix-blend-mode: screen;
  /* or multiply / lighten depending on mask type */
  opacity: 0.1;
  background-size: cover;
  background-position: center;
  pointer-events: none;
}

.shineBackground {
  opacity: 0.1;
  mix-blend-mode: multiply;
  background: radial-gradient(circle at 50% 50%, #FFFFFF55, #00000055);
}

.holographicBackground {
  opacity: 0.5;
  mix-blend-mode: color-burn;
  background: conic-gradient(from 70deg at 0 0, #ff6ec7, #ffc36b, #6effd1, #6b7eff, #ff6ec7)
}

/* Shine animation: moves diagonally across the sticker */
/* @keyframes shineMove {
  0% { transform: translateX(-100%) rotate(20deg); }
  100% { transform: translateX(100%) rotate(20deg); }
}
.animate-shine {
  animation: shineMove 1.5s linear infinite;
} */

/* Holographic gradient rotation */
/* @keyframes holoRotate {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
.animate-holo {
  animation: holoRotate 3s linear infinite;
} */
</style>