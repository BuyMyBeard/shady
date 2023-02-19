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

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord/iResolution.xy;
    fragColor = texture(iChannel0, uv);
}

////////////// Shadertoy END
void main(void) { mainImage(fragColor, FlutterFragCoord()); }
