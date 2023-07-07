extends Node2D

var type = Global.Type.PAWN
var team = Global.Team.GREEN
var tile = Vector2i()

func set_tile(tile_coords, pos_coords):
	tile = tile_coords
	position = pos_coords
	
