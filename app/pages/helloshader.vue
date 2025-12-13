<template>
    <motion.div @pointermove="handleMove" @pointerleave="handleLeave" class="shader-container sticker relative" :style="{
        transform: stickerTransform,
        boxShadow: boxShadow,
        width: `${sticker.width}px`,
        height: `${sticker.height}px`
    }">
        <canvas ref="canvas"></canvas>
    </motion.div>
</template>

<script setup lang="ts">
const sticker = defineProps<{
    main: string;
    mask: string;
    width: number;
    height: number;
}>();
import { motion, useMotionTemplate, useMotionValue, useSpring } from "motion-v";
import { onMounted, ref } from "vue";

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

const canvas = ref();

onMounted(() => {
    const gl = canvas.value.getContext("webgl");
    if (!gl) return;

    // Vertex shader (basic passthrough)
    const vertexShaderSource = `
    attribute vec2 position;
    void main() {
      gl_Position = vec4(position, 0.0, 1.0);
    }
  `;

    // Fragment shader (GLSL "Hello World")
    const fragmentShaderSource = `
    precision mediump float;
    void main() {
      gl_FragColor = vec4(.5, .9, .1, 1);
    }
  `;

    function createShader(type: any, source: any) {
        const shader = gl.createShader(type);
        gl.shaderSource(shader, source);
        gl.compileShader(shader);
        return shader;
    }

    const vertexShader = createShader(gl.VERTEX_SHADER, vertexShaderSource);
    const fragmentShader = createShader(gl.FRAGMENT_SHADER, fragmentShaderSource);

    const program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    gl.useProgram(program);

    const buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(
        gl.ARRAY_BUFFER,
        new Float32Array([
            -1, -1,
            1, -1,
            -1, 1,
            1, 1,
        ]),
        gl.STATIC_DRAW
    );

    const position = gl.getAttribLocation(program, "position");
    gl.enableVertexAttribArray(position);
    gl.vertexAttribPointer(position, 2, gl.FLOAT, false, 0, 0);

    gl.viewport(0, 0, canvas.value.width, canvas.value.height);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
});

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

<style scoped>
.shader-container {
    width: 400px;
    height: 300px;
}

canvas {
    width: 100%;
    height: 100%;
    display: block;
}
</style>
