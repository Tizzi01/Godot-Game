shader_type canvas_item;

uniform float glow_intensity = 1.5; // 🔥 Controls brightness
uniform vec3 glow_tint = vec3(0.396, 0.686, 1.0); // 💙 #65afff blue
uniform float glow_spread = 1.5; // 🌌 Controls how far glow spreads

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Calculate distance from center of particle
    float dist = length(UV - vec2(0.5));

    // Soft falloff based on distance
    float falloff = smoothstep(1.0, 0.0, dist * glow_spread);

    // Apply glow tint and intensity with falloff
    vec3 glow = tex_color.rgb * glow_tint * glow_intensity * falloff;

    // Respect fade-out alpha
    COLOR = vec4(glow, tex_color.a) * COLOR;
}
