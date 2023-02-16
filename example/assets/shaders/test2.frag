#include <flutter/runtime_effect.glsl>

// http://www.pouet.net/prod.php?which=57245
// If you intend to reuse this shader, please add credits to 'Danilo Guanabara'

uniform float uTime;
uniform vec2 uSize;

out vec4 fragColor;

void main(void) {
	vec3 c;
	float l;
	float z = uTime;
	for(int i=0;i<3;i++) {
		vec2 uv;
		vec2 p = FlutterFragCoord().xy / uSize;
		uv = p;
		p -= .5;
		p.x *= uSize.x / uSize.y;
		z += .07;
		l = length(p);
		uv += p/l * (sin(z) + 1.) * abs(sin(l * 9. - z - z));
		c[i] = .01 / length(mod(uv, 1.) - .5);
	}

	fragColor=vec4(c / l, uTime);
}