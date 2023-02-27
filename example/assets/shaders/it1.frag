const vec2 base = vec2(.5, .5);
const vec2 p1 = vec2(.24, .18);
const vec2 p2 = vec2(-.15, -.34);
const vec2 p3 = vec2(-.33, .24);

vec2 input1 = vec2(.2, .7);

const vec3 color = vec3(1., .7, .2);

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  float input2 = .0;

  vec2 uv = (fragCoord/iResolution.xy);
  vec2 ibase = mix(base, input1, input2);

  vec2 d1 = mix(
    ibase + vec2(p1.x * cos(iTime * .31), p1.y * sin(iTime * .31)),
    input1,
    input2
  );

  vec2 d2 = mix(
    base + vec2(
      p2.x * cos(iTime * .26),
      p2.y * sin(iTime * .26)
    ),
    input1,
    input2
  );

  vec2 d3 = mix(
    base + vec2(
      p3.x * cos(iTime * .24),
      p3.y * sin(iTime * .24)
    ),
    input1,
    input2
  );

  float value  = ((distance(uv, d1) + distance(uv, d2) + distance(uv, d3)) / 3.);
  value = min(smoothstep(.2, .45, value), smoothstep(.45, .2, value));
  value = clamp(0., 1., value);

  vec3 vvalue = vec3(
    pow(value, 2.),
    pow(value, 3.),
    pow(value, 3.)
  );

  fragColor = vec4(vvalue, 1.);
}