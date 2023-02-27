vec2 c = vec2(.5, .5);
vec2 input1 = vec2(.5, .5);
//float input2 = .0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord/iResolution.xy);
    float tr = iTime + 113.4;
    float r1 = 1. - (sin(iTime * 2.3) / 60.);
    float r2 = 1. - (sin(iTime * 3.2) / 60.);

    float input2 = min(
        smoothstep(.5, .6, mod(iTime / 10., 1.)),
        smoothstep(1., .9, mod(iTime / 10., 1.))
    );

    float intensity = 1. + sin(input2 * 7.28);

    vec2 p1 = c + vec2(sin(tr * 0.2) * 0.25, cos(tr * 0.3) * 0.21);
    vec2 p2 = c + vec2(cos(tr * 0.4) * 0.11, sin(tr * 0.1) * 0.14);
    vec2 p3 = c + vec2(sin(tr * 0.3) * 0.28, cos(tr * 0.2) * 0.24);

    float d1 = (1.-distance(uv, mix(p1, input1, input2)))*r1;
    float d2 = (1.-distance(uv, mix(p2, input1, input2)))*r2;
    float d3 = (1.-distance(uv, mix(p3, input1, input2)))*r2;

    fragColor = vec4(
        pow(d1, 10.) * intensity,
        pow(d2, 13.) * intensity,
        pow(d3, 15.) * intensity,
        1.
    );
}