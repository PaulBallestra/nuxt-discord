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
    class="sticker w-[473px] h-[421px]"
    :class="{ animated: isHover }"
    style="
    --base-img: url('/sticker.png');
    --mask-img: url('/sticker-mask.png');
  ">
    <div   
    class="shineBackground w-[473px] h-[421px]"></div>
    <div class="holographicBackground w-[473px] h-[421px]"></div>
  </div>

</template>

<style unscoped>
.sticker {
  position: relative;
  overflow: hidden;
  background-image: var(--base-img);
  background-size: cover;
  background-position: center;
}

.sticker.animated {
  background: red;
  transform: scale(1.03);
}

/* MASK LAYER */
.sticker::before {
  content: "";
  position: absolute;
  inset: 0;
  background-image: var(--mask-img);

  /* important: only animate/affect this layer */
  mix-blend-mode: multiply;
  /* or multiply / lighten depending on mask type */
  opacity: 0.9;
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
</style>