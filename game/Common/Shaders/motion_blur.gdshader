shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform vec2 direction = vec2(0.0, 0.0);
uniform int samples : hint_range(2, 32) = 12;

void fragment() {
    vec4 col = vec4(0.0);
    for (int i = 0; i < samples; i++) {
        float t = float(i) / float(samples - 1) - 0.5;
        col += texture(screen_tex, SCREEN_UV + direction * t);
    }
    COLOR = col / float(samples);
}