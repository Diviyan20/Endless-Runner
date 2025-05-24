shader_type canvas_item;

uniform float flash_speed = 5.0;

void fragment() {
    float flash = abs(sin(TIME * flash_speed));
    COLOR = texture(TEXTURE, UV);
    COLOR.rgb += flash * 0.3; // glowing effect
    COLOR.a *= 0.4; // translucency
}
