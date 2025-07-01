shader_type canvas_item;

const float gray = 0.8;

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    if (color.a > 0.0) {
        color.rgb = vec3(gray, gray, gray);
    }

    COLOR = color;
}
