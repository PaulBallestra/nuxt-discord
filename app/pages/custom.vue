<script setup>
    import { motion, useMotionTemplate, useMotionValue, useSpring } from "motion-v";
    import { onMounted, ref } from "vue";
    const canvas = ref(null);
    let gl, program;
    let mouseLocation;
    let mouse = { x: 0, y: 0 };
    let stickerUrl = '/images/sticker.png';
    let stickerMaskUrl = '/images/sticker-mask.png';
    let gradient = '/images/rainbow-gradient.jpg';

    const x = useMotionValue(0);
    const y = useMotionValue(0);
    const bgX = useMotionValue(50);
    const bgY = useMotionValue(50);
    const bgRotation = useMotionValue(180);
    const shadowX = useMotionValue(0);
    const shadowY = useMotionValue(0);

    const xSpring = useSpring(x);
    const ySpring = useSpring(y);

    const stickerTransform = useMotionTemplate`
        rotateX(${xSpring}deg) rotateY(${ySpring}deg)
    `;

    onMounted(async () => {
    const fragmentShaderSource = await fetch('/shaders/fragment2.glsl').then(r => r.text())
    const vertexShaderSource = await fetch('/shaders/vertex.glsl').then(r => r.text())

    gl = canvas.value.getContext("webgl");
    if (!gl) return;

    canvas.value.width = canvas.value.clientWidth;
    canvas.value.height = canvas.value.clientHeight;

    function createShader(type, source) {
        const shader = gl.createShader(type);
        gl.shaderSource(shader, source);
        gl.compileShader(shader);
        return shader;
    }

    const vertexShader = createShader(gl.VERTEX_SHADER, vertexShaderSource);
    const fragmentShader = createShader(gl.FRAGMENT_SHADER, fragmentShaderSource);

    const baseTexture = loadTexture(gl, stickerUrl);
    const maskTexture = loadTexture(gl, stickerMaskUrl);
    const gradientTexture = loadTexture(gl, gradient);

    program = gl.createProgram();
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

    const resolutionLocation = gl.getUniformLocation(program, "u_resolution");
    mouseLocation = gl.getUniformLocation(program, "u_mouse");

    const tex0Loc = gl.getUniformLocation(program, "u_texture_0");
    const tex1Loc = gl.getUniformLocation(program, "u_texture_1");
    const tex2Loc = gl.getUniformLocation(program, "u_texture_2");

    gl.uniform1i(tex0Loc, 0);
    gl.uniform1i(tex1Loc, 1);
    gl.uniform1i(tex2Loc, 2);

    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, baseTexture);

    gl.activeTexture(gl.TEXTURE1);
    gl.bindTexture(gl.TEXTURE_2D, maskTexture);

    gl.activeTexture(gl.TEXTURE2);
    gl.bindTexture(gl.TEXTURE_2D, gradientTexture);

    gl.uniform2f(
        resolutionLocation,
        canvas.value.width,
        canvas.value.height
    );

    render();
});

function loadTexture(gl, url) {
    const texture = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, texture);

    gl.texImage2D(
        gl.TEXTURE_2D,
        0,
        gl.RGBA,
        1,
        1,
        0,
        gl.RGBA,
        gl.UNSIGNED_BYTE,
        new Uint8Array([0, 0, 0, 255])
    );

    const img = new Image();
    img.src = url;
    img.onload = () => {
        gl.bindTexture(gl.TEXTURE_2D, texture);
        gl.texImage2D(
            gl.TEXTURE_2D,
            0,
            gl.RGBA,
            gl.RGBA,
            gl.UNSIGNED_BYTE,
            img
        );
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    };

    return texture;
}

function render() {
    const currentTime = performance.now() * 0.001; // seconds

    // Pass mouse position
    gl.uniform2f(mouseLocation, mouse.x, mouse.y);

    const timeLocation = gl.getUniformLocation(program, "u_time");

    // Pass time
    gl.uniform1f(timeLocation, currentTime);

    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    requestAnimationFrame(render);
}


const handleMove = (e) => {
    const rect = e.currentTarget.getBoundingClientRect();
    mouse.x = e.clientX - rect.left;
    mouse.y = rect.height - (e.clientY - rect.top); // flip Y for GLSL

    const mouseX = e.clientX - rect.left;
    const mouseY = e.clientY - rect.top;

    // Normalize to -1 → 1
    const px = (mouseX / rect.width) * 2 - 1;
    const py = (mouseY / rect.height) * 2 - 1;

    // More natural weighting (slightly stronger X tilt)
    const ROT_X = 16;  // tilt up/down
    const ROT_Y = 32;  // tilt left/right

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
    mouse.x = 0;
    mouse.y = 0;
};

</script>

<template>
    <motion.div @pointermove="handleMove" @pointerleave="handleLeave" class="sticker-container relative backface-hidden" :style="{
        transform: stickerTransform,
        perspective: 6000
    }">
        <canvas ref="canvas" width="512px" height="512px"></canvas>
    </motion.div>
</template>

<style scoped>
.sticker-container {
    width: 512px;
    height: 512px;
    background-color: transparent;
}

canvas {
    width: 100%;
    height: 100%;
    display: block;
}
</style>
