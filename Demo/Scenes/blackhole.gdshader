shader_type canvas_item;

uniform float strength : hint_range(-1.0, 1.0) = 0.5;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform sampler2D curve;

void fragment() {
    vec2 toCenter = vec2(0.5, 0.5) - UV;
    float distToCenter = length(toCenter);
    float curveVal = texture(curve, vec2(distToCenter, 0.0)).r;

    float mask = smoothstep(0.5, 0.0, distToCenter); // ⭕ circular fade
    vec2 offset = normalize(toCenter) * curveVal * strength * mask;

    COLOR = texture(SCREEN_TEXTURE, SCREEN_UV + offset);
}