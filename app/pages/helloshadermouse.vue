<script setup>
import { onMounted, ref } from "vue";

const canvas = ref(null);
let gl, program;
let mouseLocation;
let mouse = { x: 0, y: 0 };
let stickerUrl = '/images/space-sticker.png';
let stickerMaskUrl = '/images/space-sticker-mask.png';

function onMouseMove(e) {
    const rect = e.currentTarget.getBoundingClientRect();
    mouse.x = e.clientX - rect.left;
    mouse.y = rect.height - (e.clientY - rect.top); // flip Y for GLSL
}

onMounted(async() => {
    const fragmentShaderSource = await fetch('/shaders/fragment.glsl').then(r => r.text())
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

    const tex0Loc = gl.getUniformLocation(program, "u_tex0");
    const tex1Loc = gl.getUniformLocation(program, "u_tex1");

    gl.uniform1i(tex0Loc, 0);
    gl.uniform1i(tex1Loc, 1);

    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, baseTexture);

    gl.activeTexture(gl.TEXTURE1);
    gl.bindTexture(gl.TEXTURE_2D, maskTexture);

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
    gl.uniform2f(mouseLocation, mouse.x, mouse.y);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    requestAnimationFrame(render);
}
</script>

<template>
    <div class="shader-container" @mousemove="onMouseMove">
        <canvas ref="canvas" width="666px" height="616px"></canvas>
    </div>
</template>

<style scoped>
.shader-container {
    width: 666px;
    height: 616px;
    background-color: white;
}

canvas {
    width: 100%;
    height: 100%;
    display: block;
}
</style>
