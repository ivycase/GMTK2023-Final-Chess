shader_type canvas_item;

uniform vec4 swap_input : source_color;
uniform vec4 swap_input2 : source_color;
uniform vec4 swap_output : source_color;
uniform vec4 swap_output2 : source_color;
uniform bool do_swap;

void fragment() {
	if (do_swap && distance(COLOR, swap_input) < 0.15) { //swap color over time
		COLOR = swap_output;
	}
	if (do_swap && distance(COLOR, swap_input2) < 0.15) {
		COLOR = swap_output2;
	}
}