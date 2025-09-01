shader_type canvas_item;

uniform float glow_strength = 1.0;
uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 1.0, 1.0); // Electric blue

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = tex_color * glow_color * glow_strength;
}