shader_type canvas_item;

uniform float glow_intensity = 1.5;
uniform vec3 glow_tint = vec3(0.396, 0.686, 1.0);
uniform float glow_spread = 1.5;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float dist = length(UV - vec2(0.5));
    float falloff = smoothstep(1.0, 0.0, dist * glow_spread);

    // Use modulate.a to fade both base and glow together
    float fade = COLOR.a;

    // Base color
    vec3 base = tex_color.rgb * COLOR.rgb;

    // Glow scaled by fade and falloff
    vec3 glow = base * glow_tint * glow_intensity * falloff * fade;

    // Final color blends base and glow, alpha fades both
    COLOR = vec4(base + glow, tex_color.a * fade);
}