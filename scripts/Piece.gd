extends Node2D

@onready var sprite = get_node("Sprite")
@onready var green_pieces = [preload("res://sprites/pieces/black_pawn.png"), 
							 preload("res://sprites/pieces/black_knight.png"), 
							 preload("res://sprites/pieces/black_bishop.png"),
							 preload("res://sprites/pieces/black_rook.png"),
							 preload("res://sprites/pieces/black_queen.png"),
							 preload("res://sprites/pieces/black_king.png")]
@onready var pink_pieces = [preload("res://sprites/pieces/white_pawn.png"), 
							 preload("res://sprites/pieces/white_knight.png"), 
							 preload("res://sprites/pieces/white_bishop.png"),
							 preload("res://sprites/pieces/white_rook.png"),
							 preload("res://sprites/pieces/white_queen.png"),
							 preload("res://sprites/pieces/white_king.png")]

var type = Global.Type.PAWN
var team = Global.Team.GREEN
var tile = Vector2i()

func _ready():
	match team:
		Global.Team.GREEN:
			sprite.texture = green_pieces[type]
		Global.Team.PINK:
			sprite.texture = pink_pieces[type]

func set_tile(tile_coords, pos_coords):
	tile = tile_coords
	position = pos_coords

func get_pattern():
	match type:
		Global.Type.PAWN:
			return get_pawn_pattern()
		Global.Type.KING:
			return get_king_pattern()
			
func get_pawn_pattern():
	match team:
		Global.Team.GREEN:
			return [Vector2i(0, 1)]
		Global.Team.PINK:
			return [Vector2i(0, -1)]

func get_king_pattern():
	return [Vector2i(1, 1),   Vector2i(0, 1), Vector2i(-1, 1),
			Vector2i(1, 0),                   Vector2i(-1, 0),
			Vector2i(1, -1), Vector2i(0, -1), Vector2i(-1, -1)]
