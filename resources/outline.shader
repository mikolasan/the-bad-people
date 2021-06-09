shader_type canvas_item;
uniform float outline_width = 5.0;
uniform vec4 outline_color: hint_color;

void fragment(){
    COLOR = mix(vec4(1.0, 0.0, 0.0, 1.0), vec4(0.0, 1.0, 0.0, 0.0), 0.7);
}