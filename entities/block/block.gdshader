shader_type canvas_item;
render_mode blend_mix;

uniform float radius = 0.1;
uniform float thickness = 0.01;
uniform bool border_mode = false;

// 0.0 = discard everything
// 1.0 = draw everything
uniform float visible_percent : hint_range(0.0, 1.0) = 1.0;

// softness of the cutoff fade
uniform float cutoff_softness : hint_range(0.0, 0.25) = 0.02;

varying vec4 v_modulate_color;

float rounded_box(vec2 uv, float r) {
    vec2 b = vec2(0.5 - r);
    vec2 p = uv - vec2(0.5);

    vec2 d = abs(p) - b;

    float outside_dist = length(max(d, 0.0));
    float inside_dist = min(max(d.x, d.y), 0.0);

    return outside_dist + inside_dist - r + (thickness * 0.5);
}

void vertex() {
	v_modulate_color = COLOR;
}

void fragment() {
    vec2 uv = UV;

    float dist = rounded_box(uv, radius);

    vec4 col = v_modulate_color * texture(TEXTURE, UV);

    float edge = abs(dist);

    // Fill (inside shape)
    float fill = smoothstep(0.0, 0.001, -dist);

    // Border (thin band around edge)
    float border = smoothstep(thickness, 0.0, edge);

    float shape_alpha;

    if (border_mode) {
        shape_alpha = border;
    } else {
        shape_alpha = max(fill, border);
    }

    // Soft top cutoff
    float cutoff = 1.0 - visible_percent;

    // Fully visible below cutoff,
    // smoothly fades near the edge
    float reveal =
        smoothstep(cutoff - cutoff_softness,
                   cutoff + cutoff_softness,
                   uv.y);

    col.a *= shape_alpha * reveal;

    COLOR =  col;
}