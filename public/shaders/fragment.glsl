#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform sampler2D u_tex0;
uniform sampler2D u_tex1;

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;

    // rotate 180° X-axis
    uv.y = 1.0 - uv.y;

    vec3 base = texture2D(u_tex0, uv).rgb;
    float mask = texture2D(u_tex1, uv).r;

    float d = distance(gl_FragCoord.xy, u_mouse);
    float shine = smoothstep(250.0, 0.0, d);

        // shine only where mask is white
    float maskedShine = shine * mask;

    vec3 shineColor = vec3(1.0);

    vec3 finalColor = base + maskedShine * shineColor;

    gl_FragColor = vec4(finalColor, 1.0);
}