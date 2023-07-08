extends Node2D

var type = Global.Type.PAWN
var team = Global.Team.GREEN
var tile = Vector2i()

func set_tile(tile_coords, pos_coords):
	tile = tile_coords
	position = pos_coords

func get_pattern():
	match type:
		Global.Type.KING:
			return get_king_pattern()

func get_king_pattern():
	return [Vector2i(1, 1),   Vector2i(0, 1), Vector2i(-1, 1),
			Vector2i(1, 0),                   Vector2i(-1, 0),
			Vector2i(1, -1), Vector2i(0, -1), Vector2i(-1, -1)]
