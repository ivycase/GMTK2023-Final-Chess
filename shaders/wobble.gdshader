/* 
Earthbound battle backgrounds shader with scrolling effect and palette cycling like in the original game.
by @retr0_dev, modified by @absolutelyivy
	
Apply the shader to a TextureRect or a Sprite. Use a texture with some shapes in a transparent background for best results.
You can then use a ColorRect or another method to paint the background.
You can use the shader on multiple TextureRects and obtain a double-buffer effect tweaking the values for each one, remember to Make Unique the shader material.
*/
shader_type canvas_item;

uniform float amplitude = 0.075;
uniform float frequency = 10.0;
uniform float speed = 2.0;
uniform float amplitude_vertical = 0.0;
uniform float frequency_vertical = 0.0;
uniform float speed_vertical = 0.0;
uniform vec2 scroll_direction = vec2(0.0, 0.0);
uniform float scrolling_speed = 0.08;
uniform vec4 color_shift : source_color;
uniform float shift_amount = 0.5;

void fragment()
{
	float diff_x = amplitude * sin((frequency * UV.y) + (speed * TIME));
	float diff_y = amplitude_vertical * sin((frequency_vertical * UV.y)  + (speed_vertical * TIME));
	vec2 scroll = scroll_direction * TIME * scrolling_speed;
	COLOR = texture(TEXTURE, vec2(UV.x + diff_x, UV.y + diff_y) + scroll);
	COLOR = mix(COLOR, color_shift, shift_amount);
}