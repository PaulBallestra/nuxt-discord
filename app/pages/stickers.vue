<script setup lang="ts">
import { ref } from "vue"
import { motion, useMotionTemplate, useMotionValue, useSpring } from "motion-v"

const STICKER_HALF_ROTATION_RANGE = 16
const STICKER_ROTATION_RANGE = 32

const isHover = ref(false)
const x = useMotionValue<number>(0)
const y = useMotionValue<number>(0)
const bgY = useMotionValue<number>(50);
const bgX = useMotionValue<number>(50);
const bgRotation = useMotionValue<number>(32);
const shadowX = useMotionValue<number>(0);
const shadowY = useMotionValue<number>(0);

const xSpring = useSpring(x);
const ySpring = useSpring(y);
const bgRotationSpring = useSpring(bgRotation)
const bgXSpring = useSpring(bgX);
const bgYSpring = useSpring(bgY);
const shadowXSpring = useSpring(shadowX);
const shadowYSpring = useSpring(shadowY);

const stickerTransform = useMotionTemplate`rotateX(${xSpring}deg) rotateY(${ySpring}deg)`;
const stickerBoxshadow = useMotionTemplate`${shadowXSpring}px ${shadowYSpring}px 25px rgba(50, 50, 93, 0.16)`
const shineBackgroundRadialGradient = useMotionTemplate`
    radial-gradient(circle at ${bgXSpring}% ${bgYSpring}%, #FFFFFF, #ADB5BD)
`;
const holographicBackgroundConicGradient = useMotionTemplate`
    conic-gradient(from ${bgRotationSpring}deg at 0 0,#ff6ec7,#ffc36b,#6effd1,#6b7eff,#ff6ec7)
`;

const handleMove = (e: PointerEvent) => {
    const rect = (e.target as HTMLElement).getBoundingClientRect()
    const width = rect.width;
    const height = rect.height;

    const mouseX = e.clientX - rect.left;
    const mouseY = e.clientY - rect.top;

    const rX = ((mouseY / height) * STICKER_ROTATION_RANGE - STICKER_HALF_ROTATION_RANGE) * -1;
    const rY = (mouseX / width) * STICKER_ROTATION_RANGE - STICKER_HALF_ROTATION_RANGE;
    x.set(-rX);
    y.set(-rY);

    const newRotation = (mouseX / rect.width) * STICKER_HALF_ROTATION_RANGE; // rotate full circle horizontally
    bgRotation.set(newRotation);
    bgX.set((mouseX / rect.width) * 100);
    bgY.set((mouseY / rect.height) * 100);

    shadowX.set((mouseX / rect.width - 0.5) * 20); // -10 → +10
    shadowY.set((mouseY / rect.height - 0.5) * 20); // -10 → +10
}

const startAnim = () => {
    isHover.value = true
}

const stopAnim = () => {
    isHover.value = false
    x.set(0);
    y.set(0);
    bgRotation.set(32)
    bgX.set(50);
    bgY.set(50);
    shadowX.set(0);
    shadowY.set(0);
}
</script>
<template>
    <motion.div @pointermove="handleMove" @pointerenter="startAnim" @pointerleave="stopAnim"
        class="sticker w-[666px] h-[616px]" :style="{ transform: stickerTransform }">
        <!-- Base sticker -->
        <div class="w-full h-full bg-center bg-cover bg-no-repeat" :style="{ 'background-image': 'url(/sticker.png)' }"></div>
        <motion.div class="shineEffect w-full h-full absolute inset-0" :style="{ background: shineBackgroundRadialGradient }"></motion.div>
        <motion.div class="holographicEffect w-full h-full absolute inset-0" :style="{background: holographicBackgroundConicGradient}"></motion.div>
        <motion.div class="holographicEffect absolute w-full h-ful inset-0" :style="{background: holographicBackgroundConicGradient}">
            <div class="w-full h-full relative inset-0" :style="{ backgroundImage: 'url(/holographic-background.jpg)', backgroundRepeat: 'no-repeat', backgroundSize: 'cover' }"></div>
        </motion.div>
    </motion.div>
</template>

<style>
.sticker {
    position: relative;
    overflow: hidden;
    background-image: var(--base-img);
    background-size: cover;
    background-position: center;
    transform-style: "preserve-3d";
    perspective: 2500px;
    will-change: "transform, box-shadow, filter";
}

.shineEffect {
    mix-blend-mode: multiply;
    -webkit-mask-image: url('/sticker-mask.png');
    mask-image: url('/sticker-mask.png');
    mask-size: cover;
    mask-repeat: no-repeat;
    opacity: 1;
}

.holographicEffect {
    mix-blend-mode: saturation;
    -webkit-mask-image: url('/sticker-mask.png');
    mask-image: url('/sticker-mask.png');
    mask-size: cover;
    mask-repeat: no-repeat;
    opacity: 1;
}
</style>