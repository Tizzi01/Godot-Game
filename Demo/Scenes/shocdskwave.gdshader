shader_type canvas_item;

uniform float strength = 0.04;
uniform vec2 center = vec2(0.5, 0.5); // stays in local UV space
uniform float radius = 0.15;
uniform float aberration = 0.425;
uniform float width = 0.02;     // thinner ripple
uniform float feather = 0.2;    // softer edges

void fragment() {
	vec2 st = UV;

	// Distance from ripple center in local UV space
	vec2 dist_center = st - center;
	float dist = length(dist_center);

	// Ripple mask with soft edges
	float mask = (1.0 - smoothstep(radius - feather, radius, dist)) *
	             smoothstep(radius - width - feather, radius - width, dist);

	// Ripple distortion offset
	vec2 offset = normalize(dist_center) * strength * mask;
	vec2 biased_st = st - offset;

	// Chromatic aberration effect
	vec2 abber_vec = offset * aberration * mask;

	// Final color blend using local texture
	vec4 red = texture(TEXTURE, biased_st + abber_vec);
	vec4 blue = texture(TEXTURE, biased_st - abber_vec);
	vec4 ori = texture(TEXTURE, biased_st);

	// Soft glow stays
	vec4 ripple_color = vec4(red.r, ori.g, blue.b, ori.a);
	vec4 glow = vec4(0.2, 0.2, 0.4, 0.0) * mask;
	COLOR = ripple_color + glow;
}