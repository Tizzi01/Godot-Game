shader_type canvas_item;

uniform float strength = 0.04;
uniform vec2 center = vec2(0.5, 0.5); // screen-space center
uniform float radius = 0.15;
uniform float aberration = 0.425;
uniform float width = 0.02;     // thinner ripple
uniform float feather = 0.2;    // softer edges

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 st = SCREEN_UV;

	// Aspect ratio correction to keep ripple circular
	float aspect_ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 corrected_center = vec2(center.x, center.y * aspect_ratio);
	vec2 corrected_st = vec2(st.x, st.y * aspect_ratio);

	// Distance from ripple center
	vec2 dist_center = corrected_st - corrected_center;
	float dist = length(dist_center);

	// Ripple mask with smooth edges
	float mask = (1.0 - smoothstep(radius - feather, radius, dist)) *
	             smoothstep(radius - width - feather, radius - width, dist);

	// Ripple distortion offset
	vec2 offset = normalize(dist_center) * strength * mask;
	vec2 biased_st = corrected_st - offset;

	// Chromatic aberration effect
	vec2 abber_vec = offset * aberration * mask;

	// Final UV blend
	vec2 final_st = vec2(biased_st.x, biased_st.y / aspect_ratio);
	vec4 red = texture(SCREEN_TEXTURE, final_st + abber_vec);
	vec4 blue = texture(SCREEN_TEXTURE, final_st - abber_vec);
	vec4 ori = texture(SCREEN_TEXTURE, final_st);

	// Final color with soft glow
	vec4 ripple_color = vec4(red.r, ori.g, blue.b, 1.0);
	vec4 glow = vec4(0.2, 0.2, 0.4, 0.0) * mask;
	COLOR = ripple_color + glow;
}