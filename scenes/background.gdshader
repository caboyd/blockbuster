shader_type canvas_item;

uniform float cell_size = 32.0;
uniform vec2 resolution = vec2(1280.0, 720.0);

uniform float edge_softness = 1.5; // in pixels

uniform vec4 color_a : source_color = vec4(1.0);
uniform vec4 color_b : source_color = vec4(0.0);

void fragment()
{
    vec2 pixel_pos = UV * resolution;
    vec2 p = pixel_pos / cell_size;

    vec2 f = fract(p);

    // distance to nearest cell edge (0 at edge, 0.5 center)
    vec2 edge_dist = min(f, 1.0 - f);

    float blend_x = smoothstep(0.0, edge_softness / cell_size, edge_dist.x);
    float blend_y = smoothstep(0.0, edge_softness / cell_size, edge_dist.y);

    float aa = fwidth(p.x);
	float checker = smoothstep(0.5 - aa, 0.5 + aa,
	    mod(floor(p.x) + floor(p.y), 2.0));

    vec3 col = mix(color_a.rgb, color_b.rgb, checker);

    // soften toward neighbors
    float softness = min(blend_x, blend_y);

    COLOR = vec4(col, 1.0) * softness + vec4(mix(color_a.rgb, color_b.rgb, 0.5), 1.0) * (1.0 - softness);
}