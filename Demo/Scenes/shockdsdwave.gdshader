shader_type canvas_item;

uniform float strength = 0.04;
uniform vec2 center = vec2(0.5, 0.5); // screen-space center
uniform float radius = 0.15;
uniform float aberration = 0.425;
uniform float width = 0.005;     // razor-thin ripple
uniform float feather = 0.05;    // ultra-tight edges
uniform float opacity = 1.0;     // keyframe this to fade in/out

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

	// Ripple mask with ultra-tight edges
	float mask = (1.0 - smoothstep(radius - feather, radius, dist)) *
	             smoothstep(radius - width - feather, radius - width, dist);

	// Inner ring mask (even thinner)
	float core_mask = (1.0 - smoothstep(radius - feather * 0.3, radius, dist)) *
	                  smoothstep(radius - width * 0.3 - feather * 0.3, radius - width * 0.3, dist);

	// Ripple distortion offset
	vec2 offset = normalize(dist_center) * strength * mask * opacity;
	vec2 biased_st = corrected_st - offset;

	// Chromatic aberration effect
	vec2 abber_vec = offset * aberration;

	// Final UV blend
	vec2 final_st = vec2(biased_st.x, biased_st.y / aspect_ratio);
	vec4 red = texture(SCREEN_TEXTURE, final_st + abber_vec);
	vec4 blue = texture(SCREEN_TEXTURE, final_st - abber_vec);
	vec4 ori = texture(SCREEN_TEXTURE, final_st);

	// Final color with dual purple glow
	vec4 distorted = vec4(red.r, ori.g, blue.b, 1.0);
	vec4 ripple_color = mix(ori, distorted, opacity);

	// Deep purple inner ring
	vec4 core_purple = vec4(0.3, 0.0, 0.4, 0.0) * core_mask;

	// Light purple outer glow (tight and subtle)
	vec4 glow = vec4(0.6, 0.3, 0.9, 0.0) * mask * 0.3;

	COLOR = ripple_color + (core_purple + glow) * opacity;
}