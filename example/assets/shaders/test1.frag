#include <flutter/runtime_effect.glsl>

precision highp float;

uniform float time;
uniform vec2 resolution;

out vec4 fragColor;

void main(void) {
    vec2 uv = FlutterFragCoord() / 100;

    for(float i = 1.0; i < 10.0; i++){
        uv.x += 0.6 / i * cos(i * 2.5* uv.y + time);
        uv.y += 0.6 / i * cos(i * 1.5 * uv.x + time);
    }

    fragColor = vec4(vec3(0.1)/abs(sin(time-uv.y-uv.x)),1.0);
}