extends TileMap

var do_swap = false

var target_tile = null

func swap_colors():
	do_swap = !do_swap
	material.set_shader_parameter("do_swap", do_swap)

func _process(_delta):
	var mouse_pos = get_local_mouse_position()
	var coords = local_to_map(mouse_pos)
	if target_tile != null && target_tile != coords && get_cell_atlas_coords(1, target_tile) == Vector2i(6, 3):
		set_cell(1, target_tile, 0, Vector2i(5, 3))
		target_tile = null
	if get_cell_atlas_coords(1, coords) == Vector2i(5, 3):
		set_cell(1, coords, 0, Vector2i(6, 3))
		target_tile = coords
