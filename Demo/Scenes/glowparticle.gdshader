shader_type canvas_item;

uniform float strength = 0.04;
uniform vec2 center = vec2(0.5, 0.5);
uniform float radius = 0.15;
uniform float aberration = 0.425;

uniform float width = 0.0005;
uniform float feather = 0.005;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float ease_out_cubic(float t) {
	return 1.0 - pow(1.0 - t, 3.0);
}

void fragment() {
	vec2 st = SCREEN_UV;

	// Aspect ratio correction
	float aspect_ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 corrected_st = vec2(st.x, st.y * aspect_ratio);
	vec2 corrected_center = vec2(center.x, center.y * aspect_ratio);

	vec2 dist_center = corrected_st - corrected_center;
	float dist = length(dist_center);

	// ⏱️ Time-based opacity fade
	float opacity = 1.0;
	if (TIME >= 0.5 && TIME <= 1.0) {
		float t = (TIME - 0.5) / 0.5; // Normalize to 0 → 1
		opacity = 1.0 - ease_out_cubic(t);
	} else if (TIME > 1.0) {
		opacity = 0.0;
	}

	float mask = (1.0 - smoothstep(radius - feather, radius, dist)) *
	             smoothstep(radius - width - feather, radius - width, dist);

	float core_mask = (1.0 - smoothstep(radius - feather * 0.3, radius, dist)) *
	                  smoothstep(radius - width * 0.3 - feather * 0.3, radius - width * 0.3, dist);

	vec2 offset = normalize(dist_center) * strength * mask * opacity;
	vec2 biased_st = corrected_st - offset;

	vec2 abber_vec = offset * aberration;
	vec2 final_st = vec2(biased_st.x, biased_st.y / aspect_ratio);

	vec4 red = texture(SCREEN_TEXTURE, final_st + abber_vec);
	vec4 blue = texture(SCREEN_TEXTURE, final_st - abber_vec);
	vec4 ori = texture(SCREEN_TEXTURE, final_st);

	vec4 distorted = vec4(red.r, ori.g, blue.b, 1.0);
	vec4 ripple_color = mix(ori, distorted, opacity);

	vec4 core_purple = vec4(0.3, 0.0, 0.4, 0.0) * core_mask;
	vec4 glow = vec4(0.6, 0.3, 0.9, 0.0) * mask * 0.3;

	COLOR = ripple_color + (core_purple + glow) * opacity;
} 