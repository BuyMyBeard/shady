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

vec2 twirl(vec2 uv, vec2 center, float strength) {
    // https://docs.unity3d.com/Packages/com.unity.shadergraph@6.9/manual/Twirl-Node.html

    vec2 uv_cen = uv - center;
    float scaled_dist = strength * length(uv_cen);
    vec2 cs = vec2(cos(scaled_dist), sin(scaled_dist));

    float x_twirl = dot(cs * vec2(1.0, -1.0), uv_cen);
    float y_twirl = dot(cs.yx, uv_cen);

    return vec2(x_twirl + center.x, y_twirl + center.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord/vec2(max(iResolution.x, iResolution.y));
    fragColor = texture(iChannel0, twirl(uv, vec2(0.5,0.5), min(1. - mod(iTime, 1.), mod(iTime, 1.))));
}

////////////// Shadertoy END
void main(void) { mainImage(fragColor, FlutterFragCoord()); }
