#include <flutter/runtime_effect.glsl>
uniform vec3 iResolution;
uniform float iTime;
uniform float iTimeDelta;
uniform float iFrameRate;
uniform vec4 iMouse;
out vec4 fragColor;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
//////////////// Shadertoy BEGIN

// Credit: bradjamesgrant @ shadertoy
// https://www.shadertoy.com/view/tsXBzS

vec3 palette(float d) {
    return mix(vec3(0.2f, 0.7f, 0.9f), vec3(1.f, 0.f, 1.f), d);
}

vec2 rotate(vec2 p, float a) {
    float c = cos(a);
    float s = sin(a);
    return p * mat2(c, s, -s, c);
}

float map(vec3 p) {
    for(int i = 0; i < 8; ++i) {
        float t = iTime * 0.2f;
        p.xz = rotate(p.xz, t);
        p.xy = rotate(p.xy, t * 1.89f);
        p.xz = abs(p.xz);
        p.xz -= .5f;
    }
    return dot(sign(p), p) / 5.f;
}

vec4 rm(vec3 ro, vec3 rd) {
    float t = 0.f;
    vec3 col = vec3(0.f);
    float d;
    for(float i = 0.f; i < 64.f; i++) {
        vec3 p = ro + rd * t;
        d = map(p) * .5f;
        if(d < 0.02f) {
            break;
        }
        if(d > 100.f) {
            break;
        }
        col += palette(length(p) * .1f) / (400.f * (d));
        t += d;
    }
    return vec4(col, 1.f / (d * 100.f));
}
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - (iResolution.xy / 2.f)) / iResolution.x;
    vec3 ro = vec3(0.f, 0.f, -50.f);
    ro.xz = rotate(ro.xz, iTime);
    vec3 cf = normalize(-ro);
    vec3 cs = normalize(cross(cf, vec3(0.f, 1.f, 0.f)));
    vec3 cu = normalize(cross(cf, cs));

    vec3 uuv = ro + cf * 3.f + uv.x * cs + uv.y * cu;

    vec3 rd = normalize(uuv - ro);

    vec4 col = rm(ro, rd);

    fragColor = col;
}

////////////// Shadertoy END
void main(void) {
    mainImage(fragColor, FlutterFragCoord());
}
