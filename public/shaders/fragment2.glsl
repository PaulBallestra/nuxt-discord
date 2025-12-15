#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265358979323846

uniform float u_time;
uniform vec2 u_mouse;
uniform vec2 u_resolution;

uniform sampler2D u_texture_0, u_texture_1, u_texture_2;

vec2 wave(vec2 st, float freq) {
	st.y += cos(st.x*freq + u_mouse.y / u_resolution.y);
	return st;
}

float line(vec2 st, float width) {
    return step(width,1.0-smoothstep(.0,1.,abs(sin(st.y*PI + u_mouse.x / u_resolution.x))));
}

void main() {

    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st.y = 1.0 - st.y; // rotate 180° X-axis
    st.x *= u_resolution.x/u_resolution.y;
    
    vec4 base = texture2D(u_texture_0, st).rgba;
    vec4 mask = texture2D(u_texture_1, st).rgba;
    vec4 gradient = texture2D(u_texture_2, st).rgba;

    float d = distance(gl_FragCoord.rg, u_mouse);
    float shine = smoothstep(250.0, 0.0, d);

    vec4 maskedShine = shine * mask;

   	st *= 10.0;
   	st = wave(st, 2.0);
    vec4 linesPattern = vec4(line(st, 0.5), line(st, 0.5), line(st, 0.5), 1.0);

    vec4 finalColor = (linesPattern * mask) + base;

    gl_FragColor = vec4( finalColor + maskedShine * shine);
}