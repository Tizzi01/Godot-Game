shader_type canvas_item;

uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float glitch_offset : hint_range(0.0, 1.0) = 0.0;
uniform float glitch_speed : hint_range(0.0, 10.0) = 1.0;

void fragment() {
    vec2 uv = UV;

    // Vertical distortion
    uv.y += sin(uv.x * 50.0 + TIME * glitch_speed) * glitch_offset * glitch_intensity;

    // Color channel separation (vertical)
    vec4 tex_r = texture(TEXTURE, uv + vec2(0.0, glitch_offset * glitch_intensity));
    vec4 tex_g = texture(TEXTURE, uv);
    vec4 tex_b = texture(TEXTURE, uv - vec2(0.0, glitch_offset * glitch_intensity));

    COLOR = vec4(tex_r.r, tex_g.g, tex_b.b, tex_g.a);
}