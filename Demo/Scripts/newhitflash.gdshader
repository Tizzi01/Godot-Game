shader_type canvas_item;

uniform bool flash_on = false;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    if (flash_on) {
        // Override with solid white while preserving alpha
        COLOR = vec4(1.0, 1.0, 1.0, tex_color.a);
    } else {
        // Render the original texture color without modulate interference
        COLOR = tex_color;
    }
}