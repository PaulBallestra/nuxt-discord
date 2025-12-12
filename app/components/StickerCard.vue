<script setup lang="ts">
import {
  motion,
  useMotionValue,
  useMotionTemplate,
  useSpring
} from "motion-v";

const sticker = defineProps<{
  main: string;
  mask: string;
  width: number;
  height: number;
}>();

const x = useMotionValue(0);
const y = useMotionValue(0);
const bgX = useMotionValue(50);
const bgY = useMotionValue(50);
const bgRotation = useMotionValue(180);
const shadowX = useMotionValue(0);
const shadowY = useMotionValue(0);

const xSpring = useSpring(x);
const ySpring = useSpring(y);
const bgXSpring = useSpring(bgX);
const bgYSpring = useSpring(bgY);
const bgRotationSpring = useSpring(bgRotation);
const shadowXSpring = useSpring(shadowX);
const shadowYSpring = useSpring(shadowY);

const stickerTransform = useMotionTemplate`
  rotateX(${xSpring}deg) rotateY(${ySpring}deg)
`;

const shineBackgroundRadialGradient = useMotionTemplate`
  radial-gradient(circle at ${bgXSpring}% ${bgYSpring}%, #FFFFFF, #ADB5BD)
`;

const holographicBackgroundConicGradient = useMotionTemplate`
  conic-gradient(from ${bgRotationSpring}deg at 12% 12%,#ff6ec7,#ffc36b,#6effd1,#6b7eff,#ff6ec7)
`;

const boxShadow = useMotionTemplate`${shadowXSpring}px ${shadowYSpring}px 25px rgba(50, 50, 93, 0.16)`

const handleMove = (e: PointerEvent) => {
  const target = e.currentTarget as HTMLDivElement;
  const rect = target.getBoundingClientRect();

  const mouseX = e.clientX - rect.left;
  const mouseY = e.clientY - rect.top;

  // Normalize to -1 → 1
  const px = (mouseX / rect.width) * 2 - 1;
  const py = (mouseY / rect.height) * 2 - 1;

  // More natural weighting (slightly stronger X tilt)
  const ROT_X = 10;  // tilt up/down
  const ROT_Y = 16;  // tilt left/right

  const rX = py * -ROT_X; // invert so top tilts back
  const rY = px * ROT_Y;

  // Smooth 3D tilt
  x.set(rX);
  y.set(rY);

  // Shine/holo moves slower for realism (parallax)
  bgX.set(50 + px * 20);
  bgY.set(50 + py * 20);

  // Make rotation softer (fake FRAMER holographic spin)
  bgRotation.set((px + 1) * 180);

  // Softer shadow (not symmetric)
  shadowX.set(px * 8);
  shadowY.set(py * 8);
};

const handleLeave = () => {
  x.set(0);
  y.set(0);
  bgRotation.set(32);
  bgX.set(50);
  bgY.set(50);
  shadowX.set(0);
  shadowY.set(0);
};
</script>

<template>
  <motion.div key="" @pointermove="handleMove" @pointerleave="handleLeave" class="sticker relative rounded-2xl"
    :style="{ transform: stickerTransform, boxShadow: boxShadow, width: `${sticker.width}px`, height: `${sticker.height}px` }">
    <motion.div class="w-full h-full bg-center bg-cover bg-no-repeat"
      :style="{ backgroundImage: `url(/${sticker.main})`, boxShadow: boxShadow }">
    </motion.div>
    <motion.div class="shineEffect w-full h-full absolute inset-0" :style="{
      background: shineBackgroundRadialGradient,
      maskImage: `url(/${sticker.mask})`,
      webkitMask: `url(/${sticker.mask})`,
      maskSize: 'cover',
      maskRepeat: 'no-repeat',
    }"></motion.div>
    <motion.div class="holographicEffect absolute w-full h-ful inset-0" :style="{
      background: holographicBackgroundConicGradient,
      maskImage: `url(/${sticker.mask})`,
      webkitMask: `url(/${sticker.mask})`,
      maskSize: 'cover',
      maskRepeat: 'no-repeat',
    }">
      <div class="w-full h-full opacity-50 absolute inset-0" :style="{
        maskImage: `url(/${sticker.mask})`,
        WebkitMask: `url(/${sticker.mask})`,
        maskSize: 'cover',
        maskRepeat: 'no-repeat',
        backgroundImage: 'url(/holographic-background.jpg)',
        backgroundRepeat: 'no-repeat',
        backgroundSize: 'cover'
      }">
      </div>
    </motion.div>
    <div class="lighterEffect w-full h-full absolute inset-0" :style="{
      maskImage: `url(/${sticker.mask})`,
      WebkitMask: `url(/${sticker.mask})`,
      maskSize: 'cover',
      maskRepeat: 'no-repeat',
    }"></div>
  </motion.div>
</template>

<style>
.sticker {
  position: relative;
  overflow: hidden;
  background-image: var(--base-img);
  background-size: cover;
  background-position: center;
  transform-style: preserve-3d;
  will-change: "transform, box-shadow, filter";
}

.shineEffect {
  mix-blend-mode: multiply;
  filter: saturate(2);
  opacity: 1;
}

.holographicEffect {
  mix-blend-mode: multiply;
  background-position: center;
  filter: saturate(1.7) contrast(1.2);
  opacity: 1;
}

.lighterEffect {
  mix-blend-mode: overlay;
  background-position: center;
  background-color: rgb(255, 255, 255);
  filter: saturate(1);
  opacity: 1;
}
</style>