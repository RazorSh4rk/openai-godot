//Shader by: Jordancjb (https://linktr.ee/jordancjb)
//Licensed under Creative Commons 0, Use as you like c:
shader_type canvas_item;

//Noise Texture
uniform sampler2D Noise;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

//Settings
uniform float Transparency = 2.0;
uniform float Slow = 25.0;

//Shader Code
void fragment() {
	COLOR = texture(screen_texture, VERTEX) * texture(Noise, texture(Noise, UV).xy + cos(TIME) / Slow) / Transparency;
}