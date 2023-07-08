extends TileMap

var do_swap = false

func swap_colors():
	do_swap = !do_swap
	material.set_shader_parameter("do_swap", do_swap)
